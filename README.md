# Capítulo V: Tactical-Level Software Design


El diseño táctico de VSafe materializa los cuatro bounded contexts del capítulo IV en microservicios independientes: Route Planning, Risk Assessment, Incident Reporting y Journey Alerts. Cada servicio mantiene su modelo de dominio, persistencia privada, contratos e imagen de despliegue. Las clases y esquemas descritos constituyen la propuesta de diseño para la implementación del MVP.

Se utiliza DDD para expresar entidades, objetos de valor, agregados, repositorios y políticas con el lenguaje del negocio. Las reglas se ejecutan en el dominio, mientras la aplicación coordina casos de uso y la infraestructura implementa acceso a datos e integraciones. Esta separación mantiene el modelo independiente del framework y de la persistencia [R1]. ADD orienta las decisiones a los drivers del capítulo IV: oportunidad, respuesta, incertidumbre, privacidad, integridad y evolución independiente [R2].

El API Gateway conserva la verificación de sesión y el enrutamiento. No se convierte en un bounded context de negocio ni accede a las bases privadas. PostgreSQL/PostGIS, RabbitMQ, NestJS/TypeScript, Vue/PrimeVue y ONNX Runtime se conservan como tecnologías propuestas del diseño estratégico.

**Criterios comunes de diseño**

- Domain Layer contiene las reglas y abstracciones; no importa NestJS, ORM, clientes HTTP ni librerías de mensajería.
- Interface Layer transforma contratos externos a comandos y consultas de Application Layer. La aplicación utiliza interfaces del dominio y puertos propios; Infrastructure Layer implementa esas abstracciones.
- El composition root de cada microservicio registra dependencias. Un DTO público o una entidad ORM no se utiliza directamente como agregado.
- Una transacción pertenece a una base y un servicio. Los identificadores externos no crean claves foráneas entre bases.
- Los contratos HTTP y eventos están versionados. Los productores de eventos usan outbox propia y los consumidores registran inbox y efecto local antes del ACK [R5].
- Las coordenadas personales del recorrido son temporales. Los eventos de recorridos no transportan geometrías ni se conserva una trayectoria continua.

**Alcance y continuidad con el capítulo IV**

Se mantiene una aplicación web adaptable para recorridos peatonales, sesión anónima y alertas mientras la aplicación esté visible y conectada. El historial es optativo en IndexedDB, limitado inicialmente a veinte consultas durante siete días. Las pantallas de este capítulo se presentan en español para la revisión académica; la interfaz contempla en_US por defecto y es_419 según la restricción declarada en el capítulo IV.

Para concretar la evaluación del tramo restante se añade UpdateJourneyProgress: el navegador proyecta la posición autorizada sobre la ruta y comunica únicamente segmentIndex, fractionAlong, observedAt y routeVersion. La última muestra reemplaza a la anterior. Este contrato amplía técnicamente US08/US10 y debe incorporarse al capítulo III junto con el cierre del recorrido y el acuse de alertas; no introduce otro microservicio.


| Decisión táctica | Driver ADD | Aplicación concreta |
| --- | --- | --- |
| Reglas encapsuladas por agregado | QA06 / QA07 | Validación de versiones, estados y transiciones sin entidades compartidas. |
| Puertos y adaptadores | QA03 / QA07 | Mapbox, ONNX, HTTP y PostgreSQL detrás de contratos propios. |
| Consulta de riesgo con abstención | QA04 | UNKNOWN con causa cuando evidencia, cobertura o modelo sean insuficientes. |
| Outbox/inbox e idempotencia | QA06 | Reentregas sin reportes o alertas duplicadas. |
| Lease temporal de recorrido | QA05 | Eliminación espacial incluso cuando el broker no pueda notificar un cierre. |
| Base y migraciones por servicio | QA09 / CON08 | Despliegue compatible sin modificar otros microservicios. |


## 5.1. Bounded Context: Route Planning


Obtener alternativas cartográficas, coordinar su evaluación y administrar el recorrido activo. El usuario decide qué ruta utilizar.


Este contexto se implementa en **Route Planning Service**, utiliza **route_planning_db** y se relaciona con US04–US09, US11, US12, TS01 y TS04. Sus drivers prioritarios son QA01, QA03, QA05, QA07 y QA09.


### 5.1.1. Domain Layer


El siguiente diccionario identifica las clases y sus miembros principales. “−” indica un atributo privado y “+” una operación pública. Los objetos de valor se crean completos y permanecen inmutables. Las interfaces definen contratos, sin estado persistente.


| Clase / categoría | Propósito | Atributos | Métodos |
| --- | --- | --- | --- |
| Journey / Aggregate Root | Controla el ciclo de vida del recorrido y sus cambios de ruta. | - id: UUID; - ownerRef: string; - status: JourneyStatus; - routeVersion: int; - activeRoute: RouteSnapshot; - progress: JourneyProgress; - expiresAt: Instant | + start(owner, route, now): Journey; + changeRoute(route, expectedVersion): void; + updateProgress(progress, expectedVersion): void; + close(reason): void; + isActive(now): boolean |
| RouteSnapshot / Value Object | Conserva la alternativa vigente durante el recorrido; es inmutable. | - routeId: UUID; - geometry: GeoJSONLineString; - distanceM: number; - durationS: number; - risk: RiskSummary | + create(data): RouteSnapshot; + remainingGeometry(progress): GeoJSONLineString |
| GeoPoint / Value Object | Representa una coordenada válida dentro del dominio. | - latitude: number; - longitude: number | + create(lat, lon): GeoPoint; + equals(other): boolean |
| JourneyProgress / Value Object | Describe el último avance válido; no conserva un historial de posiciones. | - segmentIndex: int; - fractionAlong: number; - observedAt: Instant | + create(index, fraction, time): JourneyProgress; + isNewerThan(other): boolean |
| RiskSummary / Value Object | Representa la respuesta del contrato de riesgo sin importar entidades externas. | - level: RiskLevel; - methodVersion: string; - validUntil: Instant; - unknownCause: string? | + fromContract(dto): RiskSummary; + isUsable(now): boolean |
| RouteComparisonService / Domain Service | Ordena y compara alternativas mediante criterios explícitos. | - allowedMode: string | + compare(routes, criterion): RouteSnapshot[]; + validateSelection(route, now): void |
| JourneyRepository / Interface | Abstrae la persistencia del agregado Journey. | Sin estado. | + findOwned(id, owner): Journey?; + save(journey, expectedVersion): void; + deleteExpired(now): int |
| RouteProvider / Interface | Puerto cartográfico que evita dependencias del SDK externo. | Sin estado. | + findAlternatives(origin, destination): RouteSnapshot[] |
| RiskAssessmentPort / Interface | Puerto para obtener evaluaciones por contrato HTTP. | Sin estado. | + assess(routes, time): RiskSummary[] |
| JourneyStatus / Enumeration | Delimita el estado del recorrido. | ACTIVE; CLOSED; EXPIRED | Valores de enumeración. |


**Reglas e invariantes**


1. Un recorrido tiene propietario de sesión, estado y una versión positiva. Solo un propietario autorizado puede modificarlo o cerrarlo.
2. Solo un recorrido ACTIVE puede cambiar de ruta o actualizar su progreso. Un cambio de ruta incrementa routeVersion y reinicia el avance.
3. La geometría, duración y distancia deben ser válidas. El riesgo UNKNOWN permite comparar los demás criterios, pero no afirmar menor riesgo.
4. Una actualización de avance debe coincidir con la versión vigente, estar dentro de los segmentos de la ruta y ser posterior al último observedAt aceptado.
5. El cierre es idempotente. El estado espacial temporal se elimina en un máximo de cinco minutos después del cierre o revocación comunicada a VSafe. expiresAt se fija a cinco minutos y solo se renueva al aceptar un progreso autorizado; la inactividad también provoca expiración.
6. El historial de consultas pertenece al navegador. No se almacena una trayectoria continua ni un historial personal de rutas en el microservicio.


| Origen | Relación | Destino | Multiplicidad / significado |
| --- | --- | --- | --- |
| Journey | composition | RouteSnapshot | 1 → 1; ruta vigente |
| Journey | composition | JourneyProgress | 1 → 1; último avance |
| RouteSnapshot | composition | RiskSummary | 1 → 1; evaluación |
| Journey | association | JourneyStatus | 1 → 1; estado |
| JourneyRepository | dependency | Journey | Dependencia de uso; persiste |
| RouteComparisonService | dependency | RouteSnapshot | Dependencia de uso; compara |
| RouteProvider | dependency | GeoPoint | Dependencia de uso; recibe |
| RiskAssessmentPort | dependency | RiskSummary | Dependencia de uso; devuelve |


### 5.1.2. Interface Layer


Los adaptadores de entrada validan el contrato y la identidad; delegan las decisiones de negocio a los casos de uso. Sus DTO incluyen restricciones de tamaño, formato y valores permitidos.


| Clase | Operaciones | Responsabilidad |
| --- | --- | --- |
| RoutesController | search(request): RoutesResponse | Valida origen y destino y transforma la solicitud en SearchRoutesQuery. No calcula el riesgo. |
| JourneysController | start(), changeRoute(), updateProgress(), close() | Recibe comandos autorizados; exige versión esperada al modificar la ruta. |
| InternalJourneysController | getActive(id): ActiveJourneyContract | Proporciona a Journey Alerts el estado espacial mínimo, progreso, versión y expiración. |
| OwnedJourneyGuard | assertOwned(resource, context): void | Comprueba el propietario a partir de un contexto firmado verificado; nunca de un owner enviado por el cliente. |


### 5.1.3. Application Layer


Los handlers coordinan repositorios, políticas y puertos. Un command modifica estado; una query produce una respuesta. Esta separación de responsabilidades no obliga a utilizar bases separadas para lectura y escritura ni Event Sourcing.


| Clase / miembros principales | Entrada | Proceso |
| --- | --- | --- |
| SearchRoutesHandler; − dependencies: RouteProvider, RiskAssessmentPort y SignedRouteSelectionCodec; + execute(input): Promise<Result> | SearchRoutesQuery | Consulta RouteProvider, solicita evaluaciones a RiskAssessmentPort y produce DTO comparables dentro del presupuesto de QA01. |
| StartJourneyHandler; − dependencies: JourneyRepository, SignedRouteSelectionCodec y UnitOfWork; + execute(input): Promise<Result> | StartJourneyCommand | Valida la alternativa recibida mediante un token de selección firmado y vigente; crea Journey y registra JourneyStarted en la outbox. |
| ChangeJourneyRouteHandler; − dependencies: JourneyRepository, SignedRouteSelectionCodec y UnitOfWork; + execute(input): Promise<Result> | ChangeJourneyRouteCommand | Carga el agregado, comprueba expectedVersion, cambia la ruta y escribe JourneyRouteChanged en la misma transacción. |
| UpdateJourneyProgressHandler; − dependencies: JourneyRepository, UnitOfWork y Clock; + execute(input): Promise<Result> | UpdateJourneyProgressCommand | Reemplaza únicamente el avance actual. No publica coordenadas ni conserva muestras anteriores. |
| CloseJourneyHandler; − dependencies: JourneyRepository, UnitOfWork y Clock; + execute(input): Promise<Result> | CloseJourneyCommand | Cierra el recorrido y publica JourneyClosed sin geometría. Una tarea elimina los datos temporales. |
| GetActiveJourneyHandler; − dependencies: JourneyRepository y ResourceAuthorization; + execute(input): Promise<Result> | GetActiveJourneyQuery | Devuelve el contrato interno mínimo solo a la identidad técnica autorizada. |
| PurgeJourneysJob; − dependencies: JourneyRepository y Clock; + run(now): Promise<int> | Purga temporal | Elimina geometrías y progreso tras la expiración o plazo de cierre. No modifica las reglas del agregado. |


### 5.1.4. Infrastructure Layer


Cada implementación se registra por inyección de dependencias en el servicio propietario. Los detalles externos se traducen a tipos del contexto antes de ingresar al dominio.


| Clase / miembros principales | Abstracción / función | Implementación propuesta |
| --- | --- | --- |
| MapboxRouteProvider; − client: AdapterClient; − config: AdapterConfig; + findAlternatives(origin, destination): RouteSnapshot[] | RouteProvider | Traduce respuestas de Directions a RouteSnapshot mediante ACL, timeout de 2 s y Circuit Breaker. |
| HttpRiskAssessmentAdapter; − client: AdapterClient; − config: AdapterConfig; + assess(routes, time): RiskSummary[] | RiskAssessmentPort | Invoca POST /internal/v1/risk-assessments con identidad técnica y timeout inicial de 1 s; ante fallo devuelve UNKNOWN. |
| PostgresJourneyRepository; − dataSource: PrivateDataSource; + findOwned(id, owner): Journey?; + save(journey, expectedVersion): void; + deleteExpired(now): int | JourneyRepository | Mapea el agregado a journeys y aplica control optimista de versión. |
| SignedRouteSelectionCodec; − client: AdapterClient; − config: AdapterConfig; + sign(route, owner, expiresAt): string; + verify(token, owner): RouteSnapshot | Puerto de selección de Application Layer | Firma una alternativa con propietario, geometría, riesgo y expiración; la verificación impide aceptar geometría manipulada. |
| RoutePlanningUnitOfWork; − dataSource: PrivateDataSource; + run(action): Promise<Result> | Puerto transaccional de Application Layer | Guarda Journey y su evento de integración en una transacción local. |
| RoutePlanningOutboxRelay; − outboxStore: OutboxStore; − publisher: EventPublisher; + publishPending(limit): Promise<int> | Publicación técnica | Publica eventos pendientes con publisher confirms; conserva pendientes ante fallo del broker. |
| JourneyExpiryScheduler; − handler: ApplicationHandler; − clock: Clock; + tick(now): Promise<void> | Programación técnica | Invoca la purga y el cierre por expiración sin acceder a otras bases. |


### 5.1.5. Bounded Context Software Architecture Component Level Diagrams


La vista de componentes descompone el container del microservicio y conserva sus dependencias externas. Un componente expresa un bloque de responsabilidad, no necesariamente una clase individual [R3].


<p align="center">
  <img src="assets/route_planning_componentes.png" alt="Componentes de Route Planning Service" width="100%">
</p>


La entrada se traduce a casos de uso, el dominio aplica las reglas y los adaptadores utilizan exclusivamente route_planning_db. Las integraciones se ejecutan por HTTP, inferencia o mensajería según la responsabilidad del contexto. El archivo `fuentes/vsafe_componentes.dsl` contiene las cuatro vistas para Structurizr [R4].


### 5.1.6. Bounded Context Software Architecture Code Level Diagrams


El nivel de código se especifica mediante las clases del dominio y el modelo relacional. El primero representa comportamiento y relaciones; el segundo define cómo se conserva el estado.


#### 5.1.6.1. Bounded Context Domain Layer Class Diagrams


<p align="center">
  <img src="assets/route_planning_clases.png" alt="Clases de Domain Layer de Route Planning" width="100%">
</p>


El panel de relaciones explicita dirección y multiplicidad para evitar cruces visuales. El rombo representa composición; una flecha discontinua indica dependencia. Las fuentes PlantUML conservan los tipos y miembros completos; las fuentes Mermaid permiten revisar la estructura en Markdown.


#### 5.1.6.2. Bounded Context Database Design Diagram


<p align="center">
  <img src="assets/route_planning_base_datos.png" alt="Diseño de route_planning_db" width="100%">
</p>


| Tabla | Columnas y tipos | Constraints / índices |
| --- | --- | --- |
| journeys | id uuid PK; owner_ref varchar(128) NOT NULL; status varchar(16) NOT NULL; route_version integer NOT NULL; geometry geometry(LineString,4326) NOT NULL; distance_m double precision NOT NULL; duration_s double precision NOT NULL; risk_level varchar(16) NOT NULL; risk_method_version varchar(100) NULL; risk_valid_until timestamptz NULL; unknown_cause varchar(100) NULL; progress_segment integer NOT NULL; progress_fraction double precision NOT NULL; progress_observed_at timestamptz NOT NULL; started_at timestamptz NOT NULL; expires_at timestamptz NOT NULL; closed_at timestamptz NULL | CHECK status IN (ACTIVE,CLOSED,EXPIRED), route_version > 0, distance_m > 0, duration_s > 0, progress_segment >= 0 y progress_fraction entre 0 y 1. Índice owner_ref/status; geometry temporal. |
| request_keys | owner_ref varchar(128) PK parcial; operation varchar(80) PK parcial; idempotency_key varchar(128) PK parcial; request_hash char(64) NOT NULL; resource_id uuid NULL; created_at timestamptz NOT NULL; expires_at timestamptz NOT NULL | PK compuesta (owner_ref, operation, idempotency_key). El resultado retenido no contiene geometría; misma clave con cuerpo diferente produce conflicto. |
| outbox_events | event_id uuid PK; aggregate_id uuid NOT NULL; aggregate_version integer NOT NULL; event_type varchar(100) NOT NULL; schema_version integer NOT NULL; payload jsonb NOT NULL; occurred_at timestamptz NOT NULL; published_at timestamptz NULL; attempts integer NOT NULL | Payload de eventos de recorrido sin coordenadas; sin FK al agregado para conservar entrega después de la purga. Índice parcial de pendientes. |


Las claves foráneas indicadas pertenecen a esta base. Los identificadores de otros microservicios se tratan como referencias y se sincronizan mediante contratos. Outbox, inbox y checkpoints son estructuras técnicas de integración; no son agregados de negocio.


## 5.2. Bounded Context: Risk Assessment


Evaluar alternativas con datos de incidentes y un método versionado, distinguiendo clasificación utilizable e incertidumbre.


Este contexto se implementa en **Risk Assessment Service**, utiliza **risk_assessment_db** y se relaciona con US07, TS02 y TS04. Sus drivers prioritarios son QA01, QA04, QA06, QA07 y QA09.


### 5.2.1. Domain Layer


El siguiente diccionario identifica las clases y sus miembros principales. “−” indica un atributo privado y “+” una operación pública. Los objetos de valor se crean completos y permanecen inmutables. Las interfaces definen contratos, sin estado persistente.


| Clase / categoría | Propósito | Atributos | Métodos |
| --- | --- | --- | --- |
| RiskAssessment / Aggregate Root | Agrupa las evaluaciones de una solicitud y garantiza una versión común del método. | - id: UUID; - methodVersion: RiskModelVersion; - evaluatedAt: Instant; - estimates: RouteRiskEstimate[] | + create(version, now): RiskAssessment; + addEstimate(estimate): void; + complete(expectedRoutes): void |
| RouteRiskEstimate / Value Object | Expresa intensidad relativa estimada y cobertura para una alternativa. | - routeRef: string; - level: RiskLevel; - score: number?; - coverage: EvidenceCoverage; - validUntil: Instant; - unknownCause: string? | + classified(data): RouteRiskEstimate; + unknown(cause, coverage): RouteRiskEstimate |
| EvidenceCoverage / Value Object | Describe suficiencia, cobertura y sincronización de la evidencia. | - spatialRatio: number; - sampleCount: int; - lastSyncAt: Instant; - sourceWatermark: string | + isSufficient(policy, now): boolean |
| RiskModelVersion / Value Object | Identifica de forma reproducible el modelo y sus entradas. | - version: string; - checksum: string; - featureSchema: string | + create(data): RiskModelVersion; + matches(schema): boolean |
| IncidentEvidence / Value Object | Representación analítica propia de un incidente publicable. | - incidentId: UUID; - category: string; - location: GeoPoint; - observedAt: Instant; - validUntil: Instant; - sourceVersion: int | + isCurrent(now): boolean |
| RiskEstimationService / Domain Service | Aplica suficiencia, extrae características e interpreta la inferencia. | - policy: CoveragePolicy | + assess(routes, evidence, inference): RiskAssessment; + classify(score, thresholds): RiskLevel |
| CoveragePolicy / Domain Policy | Decide cuándo abstenerse de emitir una categoría de riesgo. | - maxSyncAgeS: int; - minCoverage: number; - minSamples: int | + evaluate(coverage, now): string? |
| IncidentProjectionRepository / Interface | Abstrae las consultas a evidencia espacial propia. | Sin estado. | + findRelevant(geometry, time): IncidentEvidence[]; + upsertIfNewer(evidence): void; + expire(id, version): void |
| RiskInferencePort / Interface | Puerto de ejecución de un modelo compatible. | Sin estado. | + predict(features, modelVersion): number[] |
| RiskLevel / Enumeration | Estados de salida comprensibles. | LOW; MEDIUM; HIGH; UNKNOWN | Valores de enumeración. |


**Reglas e invariantes**


1. La ausencia de reportes no genera LOW. Cobertura, muestras, vigencia y sincronización deben superar los criterios aprobados del modelo.
2. Una proyección sin sincronización comprobada durante más de 60 segundos genera UNKNOWN; el umbral procede del diseño estratégico.
3. Un resultado UNKNOWN tiene score nulo y una causa identificable. Una inferencia fallida nunca se sustituye por un valor arbitrario.
4. Todas las alternativas de una comparación usan la misma versión de método y un instante de referencia común.
5. Los duplicados se descartan por eventId y las versiones anteriores de un incidente no sobrescriben datos más recientes.
6. La puntuación representa intensidad relativa de incidentes reportados. No expresa la probabilidad individual de sufrir un delito.


| Origen | Relación | Destino | Multiplicidad / significado |
| --- | --- | --- | --- |
| RiskAssessment | composition | RouteRiskEstimate | 1 → 1..*; resultados |
| RiskAssessment | composition | RiskModelVersion | 1 → 1; método |
| RouteRiskEstimate | composition | EvidenceCoverage | 1 → 1; cobertura |
| RouteRiskEstimate | association | RiskLevel | 1 → 1; nivel |
| RiskEstimationService | association | CoveragePolicy | 1 → 1; aplica |
| RiskEstimationService | dependency | RiskInferencePort | Dependencia de uso; inferencia |
| IncidentProjectionRepository | dependency | IncidentEvidence | Dependencia de uso; consulta |


### 5.2.2. Interface Layer


Los adaptadores de entrada validan el contrato y la identidad; delegan las decisiones de negocio a los casos de uso. Sus DTO incluyen restricciones de tamaño, formato y valores permitidos.


| Clase | Operaciones | Responsabilidad |
| --- | --- | --- |
| InternalRiskAssessmentsController | assess(request): AssessmentResponse | Acepta una lista acotada de geometrías desde Route Planning; verifica identidad técnica y esquema. |
| IncidentEventsConsumer | consume(envelope): void | Deserializa IncidentPublished/IncidentExpired y delega el procesamiento idempotente. |
| SynchronizationConsumer | consume(checkpoint): void | Registra el watermark confirmado y el momento de sincronización; un heartbeat no prueba procesamiento completo. |


### 5.2.3. Application Layer


Los handlers coordinan repositorios, políticas y puertos. Un command modifica estado; una query produce una respuesta. Esta separación de responsabilidades no obliga a utilizar bases separadas para lectura y escritura ni Event Sourcing.


| Clase / miembros principales | Entrada | Proceso |
| --- | --- | --- |
| AssessRoutesHandler; − dependencies: IncidentProjectionRepository, RiskInferencePort, ModelRegistry y MetadataStore; + execute(input): Promise<Result> | AssessRoutesCommand | Carga el modelo compatible y evidencia propia, invoca RiskEstimationService y almacena únicamente metadatos sin geometrías de rutas. |
| ApplyIncidentEventHandler; − dependencies: IncidentProjectionRepository y RiskInboxUnitOfWork; + handle(event): Promise<void> | IncidentPublished/IncidentExpired | Aplica la actualización y registra inbox en una transacción local; confirma al broker después del commit. |
| ReconcileIncidentProjectionHandler; − dependencies: SnapshotPort, IncidentProjectionRepository y CheckpointStore; + execute(input): Promise<Result> | ReconcileProjectionCommand | Obtiene un snapshot consistente del productor y avanza hasta el watermark; habilita evaluaciones al completar la sincronización. |
| SelectRiskModelHandler; − dependencies: ModelRegistry y RiskModelArtifactLoader; + execute(input): Promise<Result> | SelectModelCommand | Activa una versión evaluada con checksum, esquema y umbrales aprobados; mantiene la anterior para reversión. |


### 5.2.4. Infrastructure Layer


Cada implementación se registra por inyección de dependencias en el servicio propietario. Los detalles externos se traducen a tipos del contexto antes de ingresar al dominio.


| Clase / miembros principales | Abstracción / función | Implementación propuesta |
| --- | --- | --- |
| OnnxRiskInferenceAdapter; − client: AdapterClient; − config: AdapterConfig; + predict(features, modelVersion): number[] | RiskInferencePort | Carga un artefacto ONNX compatible mediante ONNX Runtime para Node.js; verifica checksum y esquema. |
| PostgisIncidentProjectionRepository; − dataSource: PrivateDataSource; + findRelevant(geometry, time): IncidentEvidence[]; + upsertIfNewer(evidence): void; + expire(id, version): void | IncidentProjectionRepository | Consulta evidence_incidents de su base; usa índices espaciales y tiempos de vigencia. |
| RiskAssessmentMetadataRepository; − client: AdapterClient; − config: AdapterConfig; + save(metadata): Promise<void> | Puerto de Application Layer | Almacena modelo, categorías agregadas y causas UNKNOWN sin coordenadas de rutas. |
| RiskInboxUnitOfWork; − dataSource: PrivateDataSource; + run(action): Promise<Result> | Puerto transaccional de Application Layer | Persiste proyección, inbox y checkpoint en la misma transacción. |
| HttpIncidentSnapshotAdapter; − client: AdapterClient; − config: AdapterConfig; + fetchPage(cursor, watermark): Promise<SnapshotPage> | Puerto de reconstrucción de Application Layer | Consulta el snapshot interno de Incident Reporting con paginación y watermark. |
| RiskModelArtifactLoader; − client: AdapterClient; − config: AdapterConfig; + load(version, checksum): Promise<ModelArtifact> | Puerto de carga de Application Layer | Obtiene el modelo de un artefacto versionado de despliegue; no descarga modelos indicados por un cliente. |


### 5.2.5. Bounded Context Software Architecture Component Level Diagrams


La vista de componentes descompone el container del microservicio y conserva sus dependencias externas. Un componente expresa un bloque de responsabilidad, no necesariamente una clase individual [R3].


<p align="center">
  <img src="assets/risk_assessment_componentes.png" alt="Componentes de Risk Assessment Service" width="100%">
</p>


La entrada se traduce a casos de uso, el dominio aplica las reglas y los adaptadores utilizan exclusivamente risk_assessment_db. Las integraciones se ejecutan por HTTP, inferencia o mensajería según la responsabilidad del contexto. El archivo `fuentes/vsafe_componentes.dsl` contiene las cuatro vistas para Structurizr [R4].


### 5.2.6. Bounded Context Software Architecture Code Level Diagrams


El nivel de código se especifica mediante las clases del dominio y el modelo relacional. El primero representa comportamiento y relaciones; el segundo define cómo se conserva el estado.


#### 5.2.6.1. Bounded Context Domain Layer Class Diagrams


<p align="center">
  <img src="assets/risk_assessment_clases.png" alt="Clases de Domain Layer de Risk Assessment" width="100%">
</p>


El panel de relaciones explicita dirección y multiplicidad para evitar cruces visuales. El rombo representa composición; una flecha discontinua indica dependencia. Las fuentes PlantUML conservan los tipos y miembros completos; las fuentes Mermaid permiten revisar la estructura en Markdown.


#### 5.2.6.2. Bounded Context Database Design Diagram


<p align="center">
  <img src="assets/risk_assessment_base_datos.png" alt="Diseño de risk_assessment_db" width="100%">
</p>


| Tabla | Columnas y tipos | Constraints / índices |
| --- | --- | --- |
| model_versions | version varchar(100) PK; checksum char(64) NOT NULL; feature_schema varchar(100) NOT NULL; artifact_ref text NOT NULL; validation_status varchar(20) NOT NULL; threshold_low double precision NULL; threshold_high double precision NULL; activated_at timestamptz NULL | Un modelo solo se activa con estado VALIDATED; CHECK threshold_low < threshold_high cuando estén definidos. artifact_ref no acepta entradas del usuario. |
| assessment_metadata | id uuid PK; model_version varchar(100) FK NULL; evaluated_at timestamptz NOT NULL; outcome_counts jsonb NOT NULL; unknown_causes jsonb NOT NULL; expires_at timestamptz NOT NULL | FK local a model_versions. Metadatos agregados sin owner, origen, destino ni geometría; retención operativa propuesta de siete días. |
| evidence_incidents | incident_id uuid PK; source_version integer NOT NULL; category varchar(50) NOT NULL; location geography(Point,4326) NOT NULL; observed_at timestamptz NOT NULL; valid_until timestamptz NOT NULL; publication_status varchar(20) NOT NULL; verification_status varchar(24) NOT NULL; updated_at timestamptz NOT NULL | incident_id es referencia externa sin FK. Índice GiST location y B-tree valid_until; upsert condicionado a source_version mayor. |
| inbox_events | consumer_name varchar(80) PK parcial; event_id uuid PK parcial; aggregate_version integer NOT NULL; processed_at timestamptz NOT NULL | PK (consumer_name,event_id). Se escribe antes del ACK dentro de la transacción del efecto. |
| sync_checkpoints | source_name varchar(80) PK; processed_watermark varchar(160) NOT NULL; confirmed_watermark varchar(160) NOT NULL; last_sync_at timestamptz NOT NULL; is_rebuilding boolean NOT NULL | La proyección se marca utilizable solo cuando el watermark procesado alcanza el confirmado. |


Las claves foráneas indicadas pertenecen a esta base. Los identificadores de otros microservicios se tratan como referencias y se sincronizan mediante contratos. Outbox, inbox y checkpoints son estructuras técnicas de integración; no son agregados de negocio.


**Detalle del método de estimación**

El entrenamiento queda fuera de la solicitud de navegación. El modelo candidato analiza intensidad de incidentes reportados por segmento y franja horaria, utilizando densidad por categoría, recencia, hora y cobertura. Antes de activarlo deben definirse datos de origen, etiquetas, ventanas temporales y umbrales, comparar con una línea base y evaluar errores por zona y horario. Se separan periodos de entrenamiento y prueba y se agrupan duplicados para evitar fuga de información.

La ejecución utiliza un artefacto ONNX compatible, no entrenamiento en producción [R8]. CoveragePolicy combina límites aprobados del modelo con la sincronización de la proyección. Mientras no existan datos y evaluación aceptables, el contrato devuelve UNKNOWN. La metadata identifica método, vigencia y causa; la representación visual no promete una probabilidad de seguridad.


## 5.3. Bounded Context: Incident Reporting


Recibir aportes comunitarios, comprobar su consistencia y administrar información publicable sin confundirla con hechos confirmados.


Este contexto se implementa en **Incident Reporting Service**, utiliza **incident_reporting_db** y se relaciona con US09, US13–US16, TS03 y TS04. Sus drivers prioritarios son QA04, QA05, QA06 y QA09.


### 5.3.1. Domain Layer


El siguiente diccionario identifica las clases y sus miembros principales. “−” indica un atributo privado y “+” una operación pública. Los objetos de valor se crean completos y permanecen inmutables. Las interfaces definen contratos, sin estado persistente.


| Clase / categoría | Propósito | Atributos | Métodos |
| --- | --- | --- | --- |
| IncidentReport / Aggregate Root | Representa la contribución de un usuario y su procesamiento. | - id: UUID; - ownerRef: string; - category: IncidentCategory; - location: ApproximateLocation; - observedAt: Instant; - description: string; - status: ReportStatus; - incidentRef: UUID?; - version: int | + submit(data): IncidentReport; + assess(result): void; + linkTo(incidentId): void; + reject(reason): void |
| PublishedIncident / Aggregate Root | Administra el ciclo de vida de un incidente consultable. | - id: UUID; - categoryCode: string; - location: ApproximateLocation; - validity: ValidityPeriod; - verification: VerificationStatus; - version: int | + publish(data): PublishedIncident; + expire(now): void; + isCurrent(now): boolean |
| IncidentCategory / Value Object | Define la categoría habilitada y su política temporal. | - code: string; - labelKey: string; - validityHours: int | + create(code, hours): IncidentCategory |
| ApproximateLocation / Value Object | Conserva la ubicación del incidente confirmada por el usuario. | - latitude: number; - longitude: number; - precisionM: number | + create(data): ApproximateLocation; + equals(other): boolean |
| ValidityPeriod / Value Object | Representa el intervalo de influencia activa del incidente. | - observedAt: Instant; - validUntil: Instant | + fromCategory(observedAt, hours): ValidityPeriod; + contains(now): boolean |
| ReportAssessmentService / Domain Service | Evalúa consistencia, vigencia y posibles duplicados. | - duplicateRadiusM: number; - duplicateWindowMin: int | + assess(report, candidates, now): AssessmentResult |
| IncidentReportRepository / Interface | Puerto de persistencia de reportes. | Sin estado. | + findOwned(id, owner): IncidentReport?; + save(report, expectedVersion): void |
| PublishedIncidentRepository / Interface | Puerto para incidentes y candidatos espaciales. | Sin estado. | + findCandidates(location, category, time): PublishedIncident[]; + save(incident, expectedVersion): void; + findCurrent(filter): PublishedIncident[] |
| ReportStatus / Enumeration | Estados del aporte comunitario. | PENDING; PUBLISHED; LINKED; REJECTED | Valores de enumeración. |
| VerificationStatus / Enumeration | Distingue procedencia comunitaria y verificación. | UNVERIFIED; CORROBORATED | Valores de enumeración. |


**Reglas e invariantes**


1. El reporte requiere categoría habilitada, ubicación confirmada, momento observado y descripción cuando la categoría sea OTHER.
2. El momento observado no puede estar en el futuro más allá de la tolerancia de reloj configurada. La vigencia se calcula desde observedAt, no desde la recepción.
3. Las comprobaciones de formato y consistencia habilitan la publicación como UNVERIFIED; no verifican la ocurrencia del hecho.
4. Un candidato similar en categoría, distancia y ventana temporal se trata como posible duplicado. La regla debe calibrarse para evitar fusionar incidentes distintos.
5. Un reporte LINKED aporta al incidente existente y no crea un segundo incidente. El conteo de reportes no aumenta automáticamente la intensidad del riesgo.
6. La publicación o expiración y su evento se guardan en la misma transacción local. Los incidentes vencidos no aparecen como activos.


| Origen | Relación | Destino | Multiplicidad / significado |
| --- | --- | --- | --- |
| IncidentReport | composition | IncidentCategory | 1 → 1; categoría |
| IncidentReport | composition | ApproximateLocation | 1 → 1; ubicación |
| IncidentReport | association | ReportStatus | 1 → 1; estado |
| PublishedIncident | composition | ValidityPeriod | 1 → 1; vigencia |
| PublishedIncident | association | VerificationStatus | 1 → 1; verificación |
| IncidentReport | association | PublishedIncident | 0..* → 0..1; referencia por ID |
| IncidentReportRepository | dependency | IncidentReport | Dependencia de uso; persiste |
| PublishedIncidentRepository | dependency | PublishedIncident | Dependencia de uso; persiste |


### 5.3.2. Interface Layer


Los adaptadores de entrada validan el contrato y la identidad; delegan las decisiones de negocio a los casos de uso. Sus DTO incluyen restricciones de tamaño, formato y valores permitidos.


| Clase | Operaciones | Responsabilidad |
| --- | --- | --- |
| IncidentReportsController | submit(), getOwned(), listOwned() | Recibe el reporte con Idempotency-Key y permite consultar estado por propietario. |
| IncidentsController | findCurrent(filters): IncidentResponse[] | Devuelve incidentes publicables filtrados por zona, categoría y vigencia; omite identidad del reportante. |
| InternalIncidentSnapshotController | snapshot(cursor, watermark): SnapshotPage | Entrega una vista consistente y paginada para reconstruir proyecciones privadas. |
| ReportOwnerGuard | assertOwner(report, context): void | Protege el acceso a reportes privados aun cuando el cliente conozca su ID. |


### 5.3.3. Application Layer


Los handlers coordinan repositorios, políticas y puertos. Un command modifica estado; una query produce una respuesta. Esta separación de responsabilidades no obliga a utilizar bases separadas para lectura y escritura ni Event Sourcing.


| Clase / miembros principales | Entrada | Proceso |
| --- | --- | --- |
| SubmitIncidentReportHandler; − dependencies: IncidentReportRepository, CategoryCatalogue, IdempotencyStore y UnitOfWork; + execute(input): Promise<Result> | SubmitIncidentReportCommand | Comprueba idempotencia, construye IncidentReport y guarda aporte pendiente y evento local. |
| AssessIncidentReportHandler; − dependencies: IncidentReportRepository, PublishedIncidentRepository y UnitOfWork; + execute(input): Promise<Result> | AssessIncidentReportCommand | Carga candidatos locales, aplica ReportAssessmentService y publica, vincula o rechaza. Persiste reportes e incidentes dentro de una sola base. |
| GetOwnedReportHandler; − dependencies: IncidentReportRepository y ResourceAuthorization; + execute(input): Promise<Result> | GetOwnedReportQuery | Produce el estado legible y su explicación sin exponer otros propietarios. |
| SearchPublishedIncidentsHandler; − dependencies: PublishedIncidentRepository; + execute(input): Promise<Result> | PublishedIncidentsQuery | Aplica filtros y limita tamaño del área y paginación. |
| ExpireIncidentsHandler; − dependencies: PublishedIncidentRepository, UnitOfWork y Clock; + execute(input): Promise<Result> | ExpireIncidentsCommand | Expira incidentes vigentes según su reloj de negocio y añade IncidentExpired a la outbox. |
| BuildIncidentSnapshotHandler; − dependencies: PublishedIncidentRepository y SnapshotStore; + execute(input): Promise<Result> | SnapshotQuery | Obtiene un watermark consistente con el orden de publicación del productor. |


### 5.3.4. Infrastructure Layer


Cada implementación se registra por inyección de dependencias en el servicio propietario. Los detalles externos se traducen a tipos del contexto antes de ingresar al dominio.


| Clase / miembros principales | Abstracción / función | Implementación propuesta |
| --- | --- | --- |
| PostgresIncidentReportRepository; − dataSource: PrivateDataSource; + findOwned(id, owner): IncidentReport?; + save(report, expectedVersion): void | IncidentReportRepository | Persiste IncidentReport y aplica versión optimista. |
| PostgisPublishedIncidentRepository; − dataSource: PrivateDataSource; + findCandidates(location, category, time): PublishedIncident[]; + save(incident, expectedVersion): void; + findCurrent(filter): PublishedIncident[] | PublishedIncidentRepository | Busca candidatos por categoría, fecha y distancia en geography con índice GiST. |
| IncidentUnitOfWork; − dataSource: PrivateDataSource; + run(action): Promise<Result> | Puerto transaccional de Application Layer | Guarda reporte, incidente y outbox; las transacciones no salen de incident_reporting_db. |
| PostgresIdempotencyStore; − dataSource: PrivateDataSource; + reserve(key, hash): Promise<Result>; + resolve(key): Promise<Result> | Puerto de Application Layer | Retiene la clave por 24 h; cuerpo diferente con igual clave devuelve conflicto. |
| IncidentOutboxRelay; − outboxStore: OutboxStore; − publisher: EventPublisher; + publishPending(limit): Promise<int> | Publicación técnica | Publica IncidentPublished/IncidentExpired mediante RabbitMQ y confirma entrega al broker. |
| IncidentAssessmentScheduler; − handler: ApplicationHandler; − clock: Clock; + tick(now): Promise<void> | Programación técnica | Reintenta reportes pendientes y ejecuta expiraciones; utiliza los casos de uso del servicio. |


### 5.3.5. Bounded Context Software Architecture Component Level Diagrams


La vista de componentes descompone el container del microservicio y conserva sus dependencias externas. Un componente expresa un bloque de responsabilidad, no necesariamente una clase individual [R3].


<p align="center">
  <img src="assets/incident_reporting_componentes.png" alt="Componentes de Incident Reporting Service" width="100%">
</p>


La entrada se traduce a casos de uso, el dominio aplica las reglas y los adaptadores utilizan exclusivamente incident_reporting_db. Las integraciones se ejecutan por HTTP, inferencia o mensajería según la responsabilidad del contexto. El archivo `fuentes/vsafe_componentes.dsl` contiene las cuatro vistas para Structurizr [R4].


### 5.3.6. Bounded Context Software Architecture Code Level Diagrams


El nivel de código se especifica mediante las clases del dominio y el modelo relacional. El primero representa comportamiento y relaciones; el segundo define cómo se conserva el estado.


#### 5.3.6.1. Bounded Context Domain Layer Class Diagrams


<p align="center">
  <img src="assets/incident_reporting_clases.png" alt="Clases de Domain Layer de Incident Reporting" width="100%">
</p>


El panel de relaciones explicita dirección y multiplicidad para evitar cruces visuales. El rombo representa composición; una flecha discontinua indica dependencia. Las fuentes PlantUML conservan los tipos y miembros completos; las fuentes Mermaid permiten revisar la estructura en Markdown.


#### 5.3.6.2. Bounded Context Database Design Diagram


<p align="center">
  <img src="assets/incident_reporting_base_datos.png" alt="Diseño de incident_reporting_db" width="100%">
</p>


| Tabla | Columnas y tipos | Constraints / índices |
| --- | --- | --- |
| incident_categories | code varchar(50) PK; label_key varchar(100) NOT NULL; validity_hours integer NOT NULL; enabled boolean NOT NULL | CHECK validity_hours > 0. Categorías iniciales ROBBERY, ASSAULT, SUSPICIOUS_ACTIVITY y OTHER; la configuración no prueba hechos. |
| published_incidents | id uuid PK; category_code varchar(50) FK NOT NULL; location geography(Point,4326) NOT NULL; precision_m double precision NOT NULL; observed_at timestamptz NOT NULL; valid_until timestamptz NOT NULL; publication_status varchar(20) NOT NULL; verification_status varchar(24) NOT NULL; version integer NOT NULL | FK local category_code; CHECK valid_until > observed_at, precision_m > 0 y version > 0. Índices GiST location y categoría/vigencia. |
| incident_reports | id uuid PK; owner_ref varchar(128) NOT NULL; category_code varchar(50) FK NOT NULL; incident_id uuid FK NULL; location geography(Point,4326) NOT NULL; precision_m double precision NOT NULL; observed_at timestamptz NOT NULL; description varchar(1000) NULL; status varchar(20) NOT NULL; rejection_reason varchar(100) NULL; version integer NOT NULL; submitted_at timestamptz NOT NULL | FK locales a incident_categories y published_incidents. CHECK status y coherencia con incident_id. Índice owner_ref/submitted_at; descripción moderada antes de exposición. |
| request_keys | owner_ref varchar(128) PK parcial; operation varchar(80) PK parcial; idempotency_key varchar(128) PK parcial; request_hash char(64) NOT NULL; resource_id uuid NULL; created_at timestamptz NOT NULL; expires_at timestamptz NOT NULL | PK compuesta. El recurso referenciado se resuelve bajo autorización, sin conservar el texto privado de la solicitud. |
| outbox_events | event_id uuid PK; aggregate_id uuid NOT NULL; aggregate_version integer NOT NULL; event_type varchar(100) NOT NULL; schema_version integer NOT NULL; payload jsonb NOT NULL; occurred_at timestamptz NOT NULL; published_at timestamptz NULL; attempts integer NOT NULL | Eventos publicables con ubicación aproximada del incidente; sin propietario ni texto libre del reportante. Índice de pendientes. |


Las claves foráneas indicadas pertenecen a esta base. Los identificadores de otros microservicios se tratan como referencias y se sincronizan mediante contratos. Outbox, inbox y checkpoints son estructuras técnicas de integración; no son agregados de negocio.


**Transiciones del reporte**

PENDING pasa a PUBLISHED si el aporte es procesable y crea información comunitaria consultable; pasa a LINKED si se vincula con un incidente existente; pasa a REJECTED ante inconsistencias no corregibles. La caducidad se expresa en PublishedIncident y en la información del reporte asociado, sin convertir una validación automática en confirmación del hecho. La categoría propuesta de actividad sospechosa exige una descripción factual y moderación para evitar señalamientos personales.


## 5.4. Bounded Context: Journey Alerts


Evaluar incidentes vigentes contra el tramo restante de un recorrido y entregar alertas autorizadas sin cambiar automáticamente la ruta.


Este contexto se implementa en **Journey Alerts Service**, utiliza **journey_alerts_db** y se relaciona con US10, US11 y TS04. Sus drivers prioritarios son QA02, QA05, QA06 y QA09.


### 5.4.1. Domain Layer


El siguiente diccionario identifica las clases y sus miembros principales. “−” indica un atributo privado y “+” una operación pública. Los objetos de valor se crean completos y permanecen inmutables. Las interfaces definen contratos, sin estado persistente.


| Clase / categoría | Propósito | Atributos | Métodos |
| --- | --- | --- | --- |
| JourneyAlert / Aggregate Root | Representa una alerta lógica identificable y su entrega. | - id: UUID; - ownerRef: string; - journeyRef: UUID; - incidentRef: UUID; - routeVersion: int; - status: DeliveryStatus; - expiresAt: Instant | + create(data): JourneyAlert; + markDelivered(at): void; + invalidate(reason): void; + isDeliverable(now, version): boolean |
| ActiveJourneyProjection / Entity | Copia temporal y mínima del recorrido obtenida por contrato autorizado. | - journeyRef: UUID; - ownerRef: string; - routeVersion: int; - remainingGeometry: GeoJSONLineString; - refreshedAt: Instant; - leaseUntil: Instant | + refresh(contract, now): void; + isFresh(now): boolean; + removeGeometry(): void |
| IncidentProjection / Entity | Vista propia de un incidente publicable y su versión. | - incidentRef: UUID; - location: GeoPoint; - category: string; - validUntil: Instant; - sourceVersion: int | + applyIfNewer(contract): void; + isCurrent(now): boolean |
| AlertKey / Value Object | Clave que evita efectos duplicados para una versión de ruta. | - incidentRef: UUID; - journeyRef: UUID; - routeVersion: int | + equals(other): boolean; + toKey(): string |
| AlertRelevancePolicy / Domain Policy | Establece pertinencia espacial, temporal y por versión. | - proximityM: number; - maxProgressAgeS: int | + evaluate(journey, incident, distanceM, now): boolean |
| JourneyAlertRepository / Interface | Puerto para alertas lógicas y reentregas. | Sin estado. | + findByKey(key): JourneyAlert?; + save(alert): void; + findDeliverable(journey, afterId): JourneyAlert[] |
| ActiveJourneyRepository / Interface | Puerto de proyecciones temporales propias. | Sin estado. | + upsert(projection): void; + findActive(id): ActiveJourneyProjection?; + deleteExpired(now): int |
| IncidentProjectionRepository / Interface | Puerto espacial de incidentes de este consumidor. | Sin estado. | + upsertIfNewer(incident): void; + findNear(remainingRoute, radiusM): IncidentProjection[] |
| DeliveryStatus / Enumeration | Distingue creación, visualización e invalidez. | CREATED; DELIVERED; INVALIDATED; EXPIRED | Valores de enumeración. |


**Reglas e invariantes**


1. Solo un recorrido activo, autorizado y con proyección vigente puede recibir alertas. El arrendamiento de su geometría temporal no supera cinco minutos.
2. El incidente debe estar vigente y próximo al tramo restante. Se mantiene el radio inicial de 200 m como parámetro por validar.
3. El avance se renueva desde Route Planning al evaluar pertinencia y al mantener la suscripción. Si no puede comprobarse un progreso vigente, se suspende la evaluación contextual.
4. UNIQUE (incident_ref, journey_ref, route_version) garantiza una alerta lógica por combinación, incluso con reentregas del broker.
5. Antes de emitir o reemitir se comprueban versión, vigencia y propietario. Un cambio de ruta invalida alertas anteriores que ya no sean aplicables.
6. DELIVERED requiere un acuse de visualización del cliente. Escribir un mensaje SSE en una conexión no prueba que haya sido visto.
7. El cierre o revocación impide nuevas entregas y activa la eliminación temporal; el cliente decide si solicita otra ruta.


| Origen | Relación | Destino | Multiplicidad / significado |
| --- | --- | --- | --- |
| JourneyAlert | composition | AlertKey | 1 → 1; identidad lógica |
| JourneyAlert | association | DeliveryStatus | 1 → 1; estado |
| AlertRelevancePolicy | dependency | ActiveJourneyProjection | Dependencia de uso; evalúa |
| AlertRelevancePolicy | dependency | IncidentProjection | Dependencia de uso; evalúa |
| JourneyAlertRepository | dependency | JourneyAlert | Dependencia de uso; persiste |
| ActiveJourneyRepository | dependency | ActiveJourneyProjection | Dependencia de uso; persiste |
| IncidentProjectionRepository | dependency | IncidentProjection | Dependencia de uso; consulta |


### 5.4.2. Interface Layer


Los adaptadores de entrada validan el contrato y la identidad; delegan las decisiones de negocio a los casos de uso. Sus DTO incluyen restricciones de tamaño, formato y valores permitidos.


| Clase | Operaciones | Responsabilidad |
| --- | --- | --- |
| JourneyAlertsController | stream(journeyId, lastEventId): SSE; acknowledge(alertId) | Autoriza la sesión propietaria y abre el flujo; recibe el acuse de visualización. |
| JourneyEventsConsumer | consume(envelope): void | Recibe JourneyStarted, JourneyRouteChanged y JourneyClosed; invalida estado incompatible. |
| IncidentEventsConsumer | consume(envelope): void | Recibe publicaciones y expiraciones y delega evaluación e inbox. |
| AlertSubscriptionGuard | assertOwned(journeyId, context): void | Comprueba propiedad con estado vigente del recorrido; una URL de stream no funciona como credencial. |


### 5.4.3. Application Layer


Los handlers coordinan repositorios, políticas y puertos. Un command modifica estado; una query produce una respuesta. Esta separación de responsabilidades no obliga a utilizar bases separadas para lectura y escritura ni Event Sourcing.


| Clase / miembros principales | Entrada | Proceso |
| --- | --- | --- |
| ApplyJourneyEventHandler; − dependencies: ActiveJourneyPort, ActiveJourneyRepository y AlertsInboxUnitOfWork; + handle(event): Promise<void> | Evento de recorrido | Consulta el estado mínimo en Route Planning, actualiza la proyección y registra inbox; el cierre elimina la copia espacial. |
| ApplyIncidentEventHandler; − dependencies: IncidentProjectionRepository y AlertsInboxUnitOfWork y EvaluateJourneyAlertsHandler; + handle(event): Promise<void> | Evento de incidente | Actualiza la proyección, invoca evaluación sobre recorridos activos y registra el efecto e inbox en una transacción. |
| EvaluateJourneyAlertsHandler; − dependencies: ActiveJourneyPort, ActiveJourneyRepository, IncidentProjectionRepository, JourneyAlertRepository y SpatialQueryPort; + execute(input): Promise<Result> | EvaluateAlertsCommand | Renueva versión y progreso, obtiene distancias por un puerto espacial y aplica AlertRelevancePolicy; crea alertas con clave única. |
| SubscribeJourneyAlertsHandler; − dependencies: ActiveJourneyPort, JourneyAlertRepository y AlertDeliveryPort; + execute(input): Promise<Result> | SubscribeAlertsQuery | Devuelve alertas vigentes, controla reconexión por Last-Event-ID y no entrega mensajes de versiones anteriores. |
| AcknowledgeAlertHandler; − dependencies: JourneyAlertRepository, ResourceAuthorization y UnitOfWork; + execute(input): Promise<Result> | AcknowledgeAlertCommand | Verifica propietario y marca visualización con una operación idempotente. |
| PurgeAlertStateHandler; − dependencies: ActiveJourneyRepository, JourneyAlertRepository y Clock; + execute(input): Promise<Result> | Purga temporal | Borra proyecciones vencidas y estado personal al cerrar; invalida suscripciones locales. |


### 5.4.4. Infrastructure Layer


Cada implementación se registra por inyección de dependencias en el servicio propietario. Los detalles externos se traducen a tipos del contexto antes de ingresar al dominio.


| Clase / miembros principales | Abstracción / función | Implementación propuesta |
| --- | --- | --- |
| HttpActiveJourneyAdapter; − client: AdapterClient; − config: AdapterConfig; + getActive(id): Promise<ActiveJourneyContract> | Puerto de Application Layer | Obtiene geometría mínima, progreso, versión y lease del propietario Route Planning; con fallo no renueva la copia. |
| PostgresJourneyAlertRepository; − dataSource: PrivateDataSource; + findByKey(key): JourneyAlert?; + save(alert): void; + findDeliverable(journey, afterId): JourneyAlert[] | JourneyAlertRepository | Inserta con clave única y resuelve conflictos de reentrega sin crear otra alerta. |
| PostgresActiveJourneyRepository; − dataSource: PrivateDataSource; + upsert(projection): void; + findActive(id): ActiveJourneyProjection?; + deleteExpired(now): int | ActiveJourneyRepository | Persiste únicamente la copia actual, sin muestras históricas de ubicación. |
| PostgisAlertIncidentRepository; − dataSource: PrivateDataSource; + upsertIfNewer(incident): void; + findNear(remainingRoute, radiusM): IncidentProjection[] | IncidentProjectionRepository | Calcula proximidad métrica con geography y ST_DWithin; no usa grados como metros. |
| SseAlertDispatcher; − client: AdapterClient; − config: AdapterConfig; + deliver(alert, connection): void; + close(connection): void | Puerto de entrega de Application Layer | Emite ID, tipo y DTO de alerta a través del gateway; mantiene heartbeats y cierre de conexión. |
| AlertsInboxUnitOfWork; − dataSource: PrivateDataSource; + run(action): Promise<Result> | Puerto transaccional de Application Layer | Guarda proyección, alerta e inbox antes del ACK manual. |
| AlertLeaseScheduler; − handler: ApplicationHandler; − clock: Clock; + tick(now): Promise<void> | Programación técnica | Renueva suscripciones conectadas y elimina leases vencidos antes de admitir nuevas solicitudes. |


### 5.4.5. Bounded Context Software Architecture Component Level Diagrams


La vista de componentes descompone el container del microservicio y conserva sus dependencias externas. Un componente expresa un bloque de responsabilidad, no necesariamente una clase individual [R3].


<p align="center">
  <img src="assets/journey_alerts_componentes.png" alt="Componentes de Journey Alerts Service" width="100%">
</p>


La entrada se traduce a casos de uso, el dominio aplica las reglas y los adaptadores utilizan exclusivamente journey_alerts_db. Las integraciones se ejecutan por HTTP, inferencia o mensajería según la responsabilidad del contexto. El archivo `fuentes/vsafe_componentes.dsl` contiene las cuatro vistas para Structurizr [R4].


### 5.4.6. Bounded Context Software Architecture Code Level Diagrams


El nivel de código se especifica mediante las clases del dominio y el modelo relacional. El primero representa comportamiento y relaciones; el segundo define cómo se conserva el estado.


#### 5.4.6.1. Bounded Context Domain Layer Class Diagrams


<p align="center">
  <img src="assets/journey_alerts_clases.png" alt="Clases de Domain Layer de Journey Alerts" width="100%">
</p>


El panel de relaciones explicita dirección y multiplicidad para evitar cruces visuales. El rombo representa composición; una flecha discontinua indica dependencia. Las fuentes PlantUML conservan los tipos y miembros completos; las fuentes Mermaid permiten revisar la estructura en Markdown.


#### 5.4.6.2. Bounded Context Database Design Diagram


<p align="center">
  <img src="assets/journey_alerts_base_datos.png" alt="Diseño de journey_alerts_db" width="100%">
</p>


| Tabla | Columnas y tipos | Constraints / índices |
| --- | --- | --- |
| active_journeys | journey_ref uuid PK; owner_ref varchar(128) NOT NULL; route_version integer NOT NULL; remaining_geometry geometry(LineString,4326) NOT NULL; progress_observed_at timestamptz NOT NULL; refreshed_at timestamptz NOT NULL; lease_until timestamptz NOT NULL | journey_ref es referencia externa sin FK. CHECK route_version > 0 y lease_until <= refreshed_at + 5 minutos. Índice owner_ref y lease_until. |
| incident_projection | incident_ref uuid PK; category varchar(50) NOT NULL; location geography(Point,4326) NOT NULL; valid_until timestamptz NOT NULL; source_version integer NOT NULL; verification_status varchar(24) NOT NULL | Referencia externa sin FK. GiST location y B-tree valid_until; ignora versiones antiguas. |
| journey_alerts | id uuid PK; journey_ref uuid FK NOT NULL; incident_ref uuid NOT NULL; owner_ref varchar(128) NOT NULL; route_version integer NOT NULL; delivery_status varchar(20) NOT NULL; created_at timestamptz NOT NULL; expires_at timestamptz NOT NULL; delivered_at timestamptz NULL | FK local journey_ref a active_journeys ON DELETE CASCADE. incident_ref conserva referencia de negocio sin FK al productor. UNIQUE (incident_ref,journey_ref,route_version); CHECK status. |
| inbox_events | consumer_name varchar(80) PK parcial; event_id uuid PK parcial; aggregate_version integer NOT NULL; processed_at timestamptz NOT NULL | PK compuesta; metadatos sin geometrías ni owner. Idempotencia de consumo por handler. |
| sync_checkpoints | source_name varchar(80) PK; processed_watermark varchar(160) NOT NULL; confirmed_watermark varchar(160) NOT NULL; last_sync_at timestamptz NOT NULL; is_rebuilding boolean NOT NULL | Controla reconstrucción y frescura de la proyección de incidentes. |


Las claves foráneas indicadas pertenecen a esta base. Los identificadores de otros microservicios se tratan como referencias y se sincronizan mediante contratos. Outbox, inbox y checkpoints son estructuras técnicas de integración; no son agregados de negocio.


**Evaluación del tramo restante y entrega**

El navegador obtiene ubicación únicamente con autorización. Route Planning conserva el último progreso y devuelve una geometría restante mediante su contrato interno. Journey Alerts renueva ese estado antes de aplicar la política; si la muestra tiene más de sesenta segundos o no corresponde a la versión actual, suspende las alertas contextuales y la interfaz informa la limitación. Sesenta segundos es un parámetro técnico inicial por validar.

Para proximidad se utiliza geography y distancia métrica. ST_DWithin acepta metros en su variante geography [R7]. SSE entrega eventos servidor-cliente y se integra mediante NestJS [R6]. La reconexión recupera alertas vigentes; un POST de acuse identifica la visualización. Ninguna alerta altera la ruta sin una decisión del usuario.


## 5.5. Contratos, consistencia y trazabilidad entre microservicios


Los contratos siguientes conservan los endpoints públicos del capítulo IV y completan las operaciones necesarias para el ciclo de vida descrito. El API Gateway enruta y retransmite; cada microservicio sigue siendo propietario de sus reglas y de su especificación OpenAPI.


| Operación / contrato | Propietario | Condiciones |
| --- | --- | --- |
| POST /api/v1/routes/search | Route Planning | Origen/destino válidos. Devuelve alternativas, incertidumbre y token de selección con expiración. |
| POST /api/v1/journeys | Route Planning | Token de selección ligado al propietario, Idempotency-Key y versión inicial. |
| PATCH /api/v1/journeys/{id}/route | Route Planning | expectedVersion y token de nueva alternativa; conflicto ante versión antigua. |
| PATCH /api/v1/journeys/{id}/progress | Route Planning | Nuevo detalle técnico: routeVersion, segmentIndex, fractionAlong y observedAt. Sin trayectoria histórica. |
| DELETE /api/v1/journeys/{id} | Route Planning | Cierre idempotente, evento durable y purga temporal. |
| POST /api/v1/incident-reports | Incident Reporting | Idempotency-Key; categoría, ubicación aproximada y momento observado. |
| GET /api/v1/incident-reports | Incident Reporting | Nuevo detalle técnico: listado de reportes de la sesión propietaria para US16. |
| GET /api/v1/incident-reports/{id} | Incident Reporting | Estado autorizado y explicación del procesamiento. |
| GET /api/v1/incidents | Incident Reporting | Filtros espaciales, categoría y vigencia; información publicable sin identidad del reportante. |
| GET /api/v1/journeys/{id}/alerts/stream | Journey Alerts | SSE autorizado con Last-Event-ID; solo alertas vigentes de la versión actual. |
| POST /api/v1/journeys/{id}/alerts/{alertId}/ack | Journey Alerts | Nuevo detalle técnico: acuse idempotente de visualización bajo autorización. |
| POST /internal/v1/risk-assessments | Risk Assessment | HTTP interno, geometrías acotadas, timeout y resultado UNKNOWN cuando corresponda. |
| GET /internal/v1/journeys/{id}/active | Route Planning | Identidad técnica; geometría mínima, último avance, versión, propietario y expiración. |
| GET /internal/v1/incidents/snapshot | Incident Reporting | Snapshot consistente y paginado con watermark para reconciliación. |


**Eventos de integración**

IncidentPublished e IncidentExpired actualizan Risk Assessment y Journey Alerts. JourneyStarted, JourneyRouteChanged y JourneyClosed actualizan Journey Alerts. Los eventos contienen eventId, occurredAt, schemaVersion, aggregateId, aggregateVersion y correlationId. Los de incidentes contienen ubicación aproximada publicable; los de recorridos transportan identificadores, versión y expiración, sin coordenadas personales.

Un evento del dominio representa un hecho dentro del contexto. La aplicación lo transforma a un contrato de integración estable para otros servicios. Los metadatos de transporte y retry no se incorporan como reglas del agregado.

**Consistencia y fallos**

Se mantiene consistencia fuerte en una transacción local y consistencia eventual entre proyecciones. La escritura de outbox evita separar estado y evento; el relay puede republicar y el inbox evita repetir efectos. Los errores no procesables utilizan reintentos limitados y cola de errores. Una versión faltante inicia reconciliación. Cada consumidor conserva su checkpoint y no trata un heartbeat recibido como prueba suficiente de haber aplicado todos los cambios [R5].

Un fallo exclusivo de Risk Assessment permite mostrar cartografía con UNKNOWN. Una caída de Mapbox impide generar nuevas alternativas, pero no bloquea reportes. Si RabbitMQ está caído, los eventos quedan pendientes y no se promete cumplir el tiempo de las alertas. Un lease no renovado elimina la copia espacial temporal.

**Retención propuesta para la implementación**

Los límites del capítulo IV se conservan para recorridos: eliminación en cinco minutos después del cierre y leases de hasta cinco minutos; historial local de veinte consultas durante siete días; idempotencia de veinticuatro horas. Se propone eliminar reportes rechazados después de siete días y retirar owner_ref de aportes publicados o vinculados después de treinta días. Los incidentes históricos desidentificados pueden conservarse para análisis mediante una política documentada. Estas retenciones adicionales deben validarse con el equipo y reflejarse en la información de privacidad. Se purgan primero descripciones con datos personales; el dataset de entrenamiento no incorpora nombres ni propietarios de sesión.

Outbox/inbox retienen metadatos al menos durante la ventana de reentrega configurada. Su limpieza exige checkpoint de reconciliación; no se borran pendientes por superar un plazo. Las tareas operativas contemplan copias y logs sin coordenadas personales del recorrido.


| Caso relevante | Verificación prevista | Driver |
| --- | --- | --- |
| Cambio concurrente de recorrido | Rechazar expectedVersion antigua sin sobrescribir la ruta vigente. | QA06 |
| Evento repetido o fuera de orden | Un solo efecto; reconciliación ante hueco de versión. | QA06 |
| Datos insuficientes o modelo no aprobado | UNKNOWN con causa; nunca LOW por ausencia de reportes. | QA04 |
| Recorrido ajeno o alerta de otra sesión | Acceso denegado sin exponer geometrías ni detalles privados. | QA05 |
| Cierre con broker caído | Sin renovación del lease; purga espacial dentro del límite. | QA05 |
| Incidente fuera del tramo restante | No generar alerta; revisar radio y avance con casos espaciales controlados. | QA02 |
| Despliegue compatible de un servicio | Los demás conservan imágenes y contratos; migración local aditiva. | QA09 |

