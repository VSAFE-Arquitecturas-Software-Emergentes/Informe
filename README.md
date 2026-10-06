
# Capítulo VI: Solution UX Design


La experiencia de VSafe facilita la comparación de recorridos peatonales y presenta la información de riesgo con su contexto, vigencia e incertidumbre. El diseño traduce las necesidades de estudiantes y trabajadores a una landing page informativa y una aplicación web adaptable a escritorio y dispositivos móviles.

La navegación se organiza por tareas de usuario. La separación interna en microservicios no aparece como menú de producto: consultar una ruta reúne cartografía y riesgo en una sola experiencia, mientras reportar y recibir alertas conservan sus propios estados de procesamiento. Las decisiones de ADD se expresan en tiempos de espera comprensibles, acceso autorizado, información insuficiente y recuperación ante fallos.


## 6.1. Style Guidelines


Las guías definen una identidad y un conjunto de componentes compartidos para la landing page y la aplicación. Los recursos se organizan en un catálogo de tokens, iconos, tipografía, botones, formularios, tarjetas y mensajes. Las decisiones visuales son propuestas para VSafe y deberán contrastarse con pruebas de comprensión y usabilidad.


### 6.1.1. General Style Guidelines


**Branding y principios visuales**

VSafe utiliza el nombre del producto acompañado de un símbolo compacto con la letra V, legible también en encabezados móviles. La identidad combina azul oscuro y verde petróleo para establecer jerarquía y continuidad entre productos. La marca comunica acompañamiento informativo; evita escudos, candados o mensajes que sugieran garantía de seguridad física.

La interfaz prioriza claridad, consistencia, control del usuario y transparencia. Los incidentes se presentan con procedencia y condición de verificación. La etiqueta de riesgo siempre indica que se trata de una estimación. Un estado vacío comunica ausencia de datos aplicables, sin convertirla en afirmación sobre las condiciones reales de una zona.

**Sistema de diseño**

Se toma Material Design como referencia de jerarquía, superficies y componentes, conforme al enunciado del curso. Para Vue se utiliza PrimeVue con tokens personalizados; su modo styled permite configurar el tema [R10]. Se mantiene una escala propia común con el HTML/CSS del Landing Page, sin asumir que PrimeVue tenga que determinar toda la identidad de marca.

**Tipografía**

Se propone Inter para la interfaz, con alternativas system-ui, Segoe UI y sans-serif. Los archivos tipográficos se alojarán en el repositorio con su licencia; los diseños adjuntos utilizan una fuente sans-serif disponible para conservar legibilidad. Se evitan fuentes decorativas y texto esencial integrado exclusivamente en imágenes.


| Uso | Desktop | Mobile | Peso / altura de línea |
| --- | --- | --- | --- |
| Título principal de landing | 48 px | 32 px | 700 / 1,15 |
| Título de sección | 32 px | 24 px | 600 / 1,25 |
| Título de vista | 24 px | 22 px | 600 / 1,3 |
| Texto principal | 16 px | 16 px | 400 / 1,5 |
| Etiquetas y botones | 14–16 px | 14–16 px | 600 / 1,4 |
| Texto complementario | 14 px | 14 px | 400 / 1,5 |


**Paleta de colores propuesta**


| Token | Color | Uso |
| --- | --- | --- |
| brand.primary | #0E7668 | CTA principal y estado seleccionado. |
| brand.heading | #12344A | Encabezados y texto principal. |
| surface.background | #F4F8FA | Fondo general. |
| surface.card | #FFFFFF | Tarjetas y formularios. |
| text.secondary | #536872 | Texto complementario. |
| risk.low | #176B3A | Etiqueta “Menor riesgo estimado”, acompañada de texto. |
| risk.medium | #925900 | Etiqueta “Riesgo estimado intermedio”. |
| risk.high | #B42318 | Etiqueta “Mayor riesgo estimado”. |
| risk.unknown | #536872 | Etiqueta “Información insuficiente”. |
| focus.ring | #1D4ED8 | Indicador de foco sobre fondo claro. |
| border.default | #CCD8DE | Separación decorativa; controles esenciales usan borde con contraste suficiente. |


Los indicadores de riesgo combinan color, etiqueta e icono. La ruta seleccionada se distingue mediante grosor, marcador y estado textual. Se verificará contraste de texto normal al menos 4,5:1 y de texto grande al menos 3:1. Los componentes esenciales y foco tendrán contraste suficiente; los objetivos de interacción adoptan 44 × 44 px como criterio de diseño, superior al mínimo de 24 × 24 CSS px indicado por WCAG 2.2 AA cuando aplica [R9].

**Espaciado, formas e iconografía**

Se usa una escala de 4, 8, 12, 16, 24, 32, 48 y 64 px. Las tarjetas tienen radio de 12 px y los campos 8 px. Los campos móviles mantienen una altura mínima de 48 px. Los iconos comparten trazo y se acompañan de nombre visible o nombre accesible. El espacio entre tarjetas evita confundir el contenido de rutas diferentes.

**Tono de comunicación**

El tono es serio, cercano, respetuoso y sereno. Las instrucciones usan verbos concretos: “Comparar rutas”, “Confirmar ubicación” y “Consultar estado”. Se evita lenguaje alarmista, culpabilizador o que asegure protección. Los errores explican el problema y el siguiente paso disponible.


| Situación | Mensaje propuesto |
| --- | --- |
| Evidencia insuficiente | Información insuficiente para estimar el riesgo de esta ruta. |
| Sin incidentes aplicables | No encontramos reportes vigentes asociados a este recorrido. |
| Reporte recibido | Recibimos tu reporte. Su estado es pendiente. |
| Publicación comunitaria | Reporte comunitario no verificado. |
| Fallo cartográfico | No podemos obtener rutas ahora. Conservamos tus puntos para que puedas reintentar. |
| Permiso de ubicación | Usaremos tu ubicación para esta función. También puedes elegir el origen en el mapa. |
| Alertas pausadas | Las alertas están pausadas. Mantén la aplicación abierta y revisa la conexión y el permiso de ubicación. |


### 6.1.2. Web, Mobile & Devices Style Guidelines


La aplicación corresponde a una experiencia web responsive. El MVP no incorpora una aplicación nativa; por ello se definen desktop browser y mobile browser. Los contratos de los microservicios se mantienen al cambiar de tamaño de pantalla. La landing page conserva la misma identidad, acciones y vocabulario.


| Aspecto | Desktop ≥ 1024 px | Tablet 768–1023 px | Mobile < 768 px |
| --- | --- | --- | --- |
| Landing | Contenedor máximo de 1280 px, 12 columnas; hero con texto y visual. | 8 columnas; se reduce separación y se reorganizan tarjetas. | 4 columnas; contenido apilado y CTA de ancho disponible. |
| Aplicación | Panel de tareas de 360–420 px y mapa flexible. | Panel lateral contraíble y mapa. | Mapa y hoja inferior; tarjetas en una columna. |
| Navegación | Encabezado con Mapa, Reportar, Mis reportes e Historial. | Mismos destinos visibles o en menú compacto. | Barra Mapa/Reportar/Historial; Mis reportes dentro de Reportar y preferencias en el encabezado. |
| Márgenes | 32–64 px según sección. | 24 px. | 16–24 px y safe areas del dispositivo. |
| Interacción | Ratón y teclado; foco visible y navegación secuencial. | Táctil y teclado cuando esté disponible. | Controles de al menos 44 × 44 px; ninguna acción depende de hover. |
| Formularios | Etiquetas persistentes y errores junto al campo. | Se conserva orden y valores. | Teclado adecuado al dato; scroll hasta el error sin borrar el formulario. |


La interfaz se adapta desde 320 px y permite ampliar texto al 200 % sin perder operaciones principales. La representación cartográfica se acompaña de una lista accesible de rutas y de controles para introducir coordenadas o elegir lugares sin depender exclusivamente del arrastre. Los mensajes críticos utilizan regiones anunciables, sin robar el foco continuamente.

Se distinguen loading, success, empty, error y disconnected. Una consulta activa muestra progreso y permite cancelar o corregir; un error no borra los puntos. La aplicación respeta reducción de movimiento y evita destellos. La selección táctil y por teclado produce el mismo resultado.

La Geolocation API requiere permiso y un contexto seguro [R12]. Durante un recorrido, la obtención de ubicación alimenta un progreso mínimo; si no existe permiso, conexión o avance reciente, se muestra la condición de pausa. El criterio inicial de actualización es como máximo una muestra cada diez segundos o cuando el avance supere veinte metros, sujeto a pruebas de batería y precisión; no se guarda una trayectoria. Las alertas no se ofrecen como notificaciones garantizadas en segundo plano.

La preferencia de idioma permite en_US y es_419. Se localizan etiquetas, fechas, mensajes y texto accesible. El idioma predeterminado declarado en el capítulo IV es inglés; en este informe se presenta la variante española para explicar el diseño.


## 6.2. Information Architecture


La organización distingue información pública de la landing page y tareas operativas de la aplicación. Los visitantes encuentran primero la propuesta, después el funcionamiento, los segmentos y la información de confianza. Los usuarios de la aplicación comienzan por el mapa y acceden a reportes, historial y preferencias sin registro obligatorio.


<p align="center">
  <img src="assets/arquitectura_informacion.png" alt="Arquitectura de información de VSafe" width="100%">
</p>


### 6.2.1. Organization Systems


Se completa la numeración con Organization Systems, solicitado en el enunciado y necesario para explicar la estructura antes de los sistemas de etiquetas. Se combinan jerarquía por contenido, secuencia por tarea y comparación matricial.


| Conjunto de información | Sistema / esquema | Aplicación |
| --- | --- | --- |
| Landing Page | Jerárquico por tópicos y audiencia | Propuesta → funcionamiento → estudiantes/trabajadores → información de confianza → CTA. |
| Planificación | Secuencial | Origen/destino → alternativas → detalle → inicio de recorrido. |
| Comparación de rutas | Matricial por criterios | Cada tarjeta expone duración, distancia, estimación, vigencia y cobertura. |
| Reportes | Secuencial y por estado | Datos → ubicación → resumen → envío; listado por pendiente/publicado/vinculado/rechazado. |
| Incidentes | Geográfico y temporal | Zona visible, categoría y vigencia; no se ordenan como ranking de lugares peligrosos. |
| Historial | Cronológico inverso | Consultas recientes primero, solo en el navegador y con consentimiento. |
| Preferencias | Por tópicos | Idioma, ubicación, historial e información de privacidad. |


### 6.2.2. Labeling Systems


Las etiquetas describen tareas y resultados de forma breve. Se usa “recorrido” para el viaje activo y “ruta” para una alternativa; “reporte” es el aporte y “incidente” la información publicable. El vocabulario conserva la distinción del DDD sin exponer nombres de servicios ni términos de infraestructura al usuario.


| Etiqueta es_419 | Etiqueta en_US | Destino / significado |
| --- | --- | --- |
| Explorar rutas | Explore routes | CTA desde la landing hacia /app/map. |
| Mapa | Map | Vista principal de planificación. |
| Origen | Origin | Punto inicial seleccionado. |
| Destino | Destination | Punto final seleccionado. |
| Usar mi ubicación | Use my location | Solicitar uso autorizado como origen. |
| Comparar rutas | Compare routes | Obtener alternativas con criterios. |
| Ver detalle | View details | Información de una ruta e incidentes. |
| Iniciar recorrido | Start journey | Activar la ruta seleccionada. |
| Finalizar recorrido | End journey | Cerrar el estado temporal y las alertas. |
| Buscar alternativa | Find alternative | Recalcular tras una alerta o cambio. |
| Reportar | Report | Formulario de aporte comunitario. |
| Confirmar ubicación | Confirm location | Aceptar el punto aproximado del incidente. |
| Mis reportes | My reports | Estados de los aportes de la sesión. |
| Historial | History | Consultas locales optativas. |
| Información insuficiente | Insufficient information | Resultado UNKNOWN con causa explicada. |
| Privacidad | Privacy | Uso de ubicación y controles de historial. |


### 6.2.3. Searching Systems


La búsqueda principal se basa en origen y destino seleccionados en el mapa, ubicación autorizada o coordenadas ingresadas mediante controles accesibles. Este alcance corresponde al adaptador cartográfico definido en el capítulo IV. Una caja de direcciones con autocompletado requeriría contratar e integrar geocodificación; por ello no se presenta como capacidad ya incluida.


| Búsqueda | Entradas / filtros | Presentación del resultado |
| --- | --- | --- |
| Alternativas de ruta | Origen y destino; modo peatonal; ordenar por duración o distancia y, cuando sea comparable, intensidad estimada. | Mapa y tarjetas con datos homogéneos. UNKNOWN aparece con explicación; no se ordena como menor riesgo. |
| Incidentes | Área visible o recorrido; categoría y vigencia. | Marcadores y lista con categoría, ubicación aproximada, momento observado y condición de verificación. |
| Mis reportes | Estado y fecha de envío; solo la sesión propietaria. | Lista cronológica y detalle del procesamiento. La paginación evita listados ilimitados. |
| Historial local | Fecha y referencia local de destino. | Últimas consultas del navegador; reutilizar ejecuta nueva búsqueda. |
| Ayuda pública | Preguntas organizadas por tópicos. | Contenido breve sobre riesgo, permisos, reportes y alcance de las alertas. |


Los controles conservan las entradas al cambiar filtros. Se muestran estados de carga, lista vacía y fuente no disponible. Si el punto está fuera de cobertura, se explica la condición y se permite corregirlo. No se confunde cobertura cartográfica con disponibilidad de evidencia de riesgo.


### 6.2.4. SEO Tags and Meta Tags


La landing page comunica la propuesta pública y puede indexarse. Las vistas de la aplicación que contienen recorridos, reportes privados o estados de sesión se definen con noindex. La directiva de indexación no sustituye autorización ni protección de datos. No se incluyen coordenadas o identificadores personales en title, description ni URLs compartibles.


| Página | Title | Description | Robots |
| --- | --- | --- | --- |
| /es-419/ | VSafe / Compara rutas con información de riesgo estimado | Compara recorridos a pie por tiempo, distancia y riesgo estimado. Consulta incidentes y decide con información disponible. | index, follow |
| /en-us/ | VSafe / Compare routes with estimated risk information | Compare walking routes by time, distance and estimated risk. Review reported incidents and choose with available information. | index, follow |
| /es-419/privacidad | Privacidad y ubicación / VSafe | Conoce cómo VSafe utiliza ubicación autorizada, datos temporales y un historial local opcional. | index, follow |
| /en-us/privacy | Privacy and location / VSafe | Learn how VSafe uses authorized location, temporary journey data and optional local history. | index, follow |
| /app/map | Planificar recorrido / VSafe | Planifica y compara alternativas con tu sesión de VSafe. | noindex, nofollow |
| /app/reports | Mis reportes / VSafe | Consulta el estado de los reportes de tu sesión. | noindex, nofollow |
| /app/history | Historial local / VSafe | Revisa consultas guardadas de forma opcional en este navegador. | noindex, nofollow |


Los valores comunes son Author = “Equipo VSafe” y Keywords = “VSafe, rutas peatonales, navegación urbana, riesgo estimado, incidentes, Lima”. Keywords se incluye por el mínimo académico solicitado, pero Google no lo utiliza para indexación o ranking [R11]. Cada variante de idioma adapta title y description y establece lang="es-419" o lang="en-US".

Se configuran viewport, canonical, hreflang recíproco es-419/en-US, og:title, og:description, og:type="website" y una imagen de marca sin datos de ubicación. La URL canónica y og:url se reemplazan por el dominio real al desplegar; no se inventa un dominio público. El sitemap enumera únicamente páginas públicas. No se generan elementos ASO en este alcance porque el MVP no se distribuye en una app store.


### 6.2.5. Navigation Systems


La landing ofrece navegación global hacia Cómo funciona, Para quién, Privacidad y Ayuda. Las secciones pueden alcanzarse por anclas descriptivas. Los CTA de estudiantes y trabajadores redirigen a la misma capacidad de planificación con contexto informativo; no necesitan duplicar aplicaciones ni crear cuentas obligatorias.

La aplicación organiza navegación global en Mapa, Reportar, Mis reportes e Historial. En móvil se conservan tres accesos principales y Mis reportes se ofrece dentro de Reportar. La navegación local permite volver de detalle a alternativas sin perder origen/destino. La navegación contextual conecta una alerta con el recálculo y un reporte enviado con su estado.

El botón Atrás del navegador respeta el estado de la vista y no cierra silenciosamente un recorrido. “Finalizar recorrido” es una acción explícita. Abandonar un formulario con cambios solicita confirmación; los errores de red conservan su contenido en memoria. No se almacenan automáticamente borradores de incidentes en el historial local.

Se proporciona salto al contenido, orden de foco consistente y nombre accesible para la vista actual. El mapa no bloquea la navegación del teclado y los resultados también se pueden revisar como lista. Una alerta anuncia información pertinente, sin imponer un cambio de ruta ni interrumpir continuamente la tarea.


## 6.3. Landing Page UI Design


La landing traduce la propuesta de navegación informada en una secuencia breve: comprender el beneficio, conocer el funcionamiento y acceder a la aplicación. El hero explica los criterios de comparación; las secciones posteriores presentan segmentos, evidencia disponible y privacidad. El CTA principal es “Explorar rutas” y conduce a la planificación peatonal.


### 6.3.1. Landing Page Wireframe


**Desktop Web Browser**


<p align="center">
  <img src="assets/landing_desktop_wireframe.png" alt="Wireframe desktop del Landing Page" width="100%">
</p>


La vista de escritorio presenta un encabezado persistente de navegación, un hero de dos columnas, tres pasos de funcionamiento, dos bloques por segmento y una sección sobre límites de información. La posición y jerarquía del CTA permiten iniciar la tarea sin revisar todo el contenido. El visual cartográfico es ilustrativo y conserva un equivalente textual.


**Mobile Web Browser**


<p align="center">
  <img src="assets/landing_mobile_wireframe.png" alt="Wireframe mobile del Landing Page" width="420">
</p>


En móvil se apilan título, explicación, CTA y mapa. Las tarjetas pasan a una columna y el menú conserva los destinos del encabezado. Los botones ocupan el ancho disponible y el contenido puede recorrerse sin desplazamiento horizontal. La información de privacidad permanece próxima a la acción de comenzar.


### 6.3.2. Landing Page Mock-up


**Desktop Web Browser**


<p align="center">
  <img src="assets/landing_desktop_mockup.png" alt="Mock-up desktop del Landing Page" width="100%">
</p>


El mock-up aplica fondo claro, títulos en azul oscuro, CTA en verde petróleo y tarjetas de superficie blanca. El mapa presenta rutas distinguibles y una tarjeta de ejemplo; los datos y el nivel de riesgo se identifican como ilustrativos. El componente de confianza explica información insuficiente y condición comunitaria de los reportes.


**Mobile Web Browser**


<p align="center">
  <img src="assets/landing_mobile_mockup.png" alt="Mock-up mobile del Landing Page" width="420">
</p>


La adaptación móvil conserva nombre, contraste, jerarquía y vocabulario. La interacción sigue una secuencia vertical y el CTA se mantiene visible entre bloques. Los textos evitan sugerir garantías sobre la integridad física y permiten acceder a la alternativa manual de origen.


## 6.4. Applications UX/UI Design


La aplicación se estructura alrededor de planificación, acompañamiento y colaboración. Las pantallas explican el estado del proceso: obtener rutas, seleccionar, iniciar, recibir información contextual, modificar o finalizar. Los reportes se presentan como aportes procesados por etapas; el usuario puede consultar su resultado.


### 6.4.1. Applications Wireframes


| Wireframe | Vista / estado | Historias y propósito |
| --- | --- | --- |
| WF01 | Planificar ruta | US04, US05 |
| WF02 | Permiso de ubicación | US05, TS04 |
| WF03 | Comparar rutas | US06, US07, US09 |
| WF04 | Detalle de ruta | US08, US09 |
| WF05 | Recorrido activo | US08, US10 |
| WF06 | Alerta del recorrido | US10, US11 |
| WF07 | Nuevas alternativas | US11 |
| WF08 | Reportar incidente | US13, US14 |
| WF09 | Ubicación del incidente | US15 |
| WF10 | Reporte recibido | US13, US16 |
| WF11 | Mis reportes | US16 |
| WF12 | Historial local | US12, TS04 |
| WF13 | Privacidad y preferencias | TS04 |
| WF14 | Servicio no disponible | TS01, QA03 |
| WF15 | Sin alternativas | US06, US11 |
| WF16 | Revisar reporte | US13–US15 |


**Aplicación de escritorio**


<p align="center">
  <img src="assets/aplicacion_desktop_wireframe.png" alt="Wireframe desktop de la aplicación" width="100%">
</p>


El panel lateral concentra puntos, filtros y comparación; el mapa presenta geometrías y contexto. La lista sigue siendo operable sin interacción cartográfica. El detalle permite consultar vigencia y causa UNKNOWN antes de iniciar el recorrido.


**Aplicación web móvil**


<p align="center">
  <img src="assets/wireframes_planificacion.png" alt="Wireframes móviles de planificacion" width="100%">
</p>


WF01–WF02 permiten definir puntos y solicitar autorización; la alternativa manual conserva el acceso.


<p align="center">
  <img src="assets/wireframes_comparacion.png" alt="Wireframes móviles de comparacion" width="100%">
</p>


WF03–WF04 presentan alternativas comparables y el detalle previo a iniciar. La intensidad estimada se muestra con vigencia y explicación.


<p align="center">
  <img src="assets/wireframes_acompanamiento.png" alt="Wireframes móviles de acompanamiento" width="100%">
</p>


WF05–WF06 distinguen recorrido activo y aparición de una alerta. El usuario elige continuar o solicitar otra opción.


<p align="center">
  <img src="assets/wireframes_recalculo.png" alt="Wireframes móviles de recalculo" width="100%">
</p>


WF07 representa nuevas alternativas; WF15 informa que no existe otra ruta aplicable. La versión activa cambia solo tras confirmar.


<p align="center">
  <img src="assets/wireframes_reporte.png" alt="Wireframes móviles de reporte" width="100%">
</p>


WF08–WF09 separan categoría/momento del incidente y confirmación espacial. Las correcciones no borran los datos del formulario.


<p align="center">
  <img src="assets/wireframes_revision.png" alt="Wireframes móviles de revision" width="100%">
</p>


WF16 muestra el resumen antes del envío; WF10 confirma recepción únicamente después de la respuesta del servidor.


<p align="center">
  <img src="assets/wireframes_seguimiento.png" alt="Wireframes móviles de seguimiento" width="100%">
</p>


WF10 confirma recepción pendiente; WF11 presenta estados sin confundir publicación con verificación.


<p align="center">
  <img src="assets/wireframes_preferencias.png" alt="Wireframes móviles de preferencias" width="100%">
</p>


WF12–WF13 permiten reutilizar con datos actuales, borrar historial y detener uso de ubicación.


<p align="center">
  <img src="assets/wireframes_errores.png" alt="Wireframes móviles de errores" width="100%">
</p>


WF14–WF15 informan fallo externo o ausencia de rutas y conservan opciones de recuperación.


Los wireframes se mantienen en baja fidelidad para revisar estructura y estados. Los mock-ups de aplicación y prototipos interactivos corresponden a puntos posteriores del capítulo VI y no forman parte de 6.4.1–6.4.2. Las vistas adjuntas no representan una aplicación ya ejecutada ni resultados de pruebas con usuarios.


### 6.4.2. Applications Wireflow Diagrams


Cada wireflow relaciona pantallas con acciones, nuevos estados y rutas alternativas. Los objetivos se aplican a los dos User Personas porque comparten las capacidades del producto; el estudiante enfatiza la llegada a clases y el trabajador la adaptación a destinos variables. Las preferencias personales no cambian el significado de riesgo ni la autorización de datos.


#### 6.4.2.1. UG01 · Comparar e iniciar un recorrido


**User goal:** Comparar e iniciar un recorrido.


**Persona e historias:** Estudiante o trabajador · US04–US09.


<p align="center">
  <img src="assets/wireflow_rutas.png" alt="UG01 · Comparar e iniciar un recorrido" width="100%">
</p>


| Desde | Acción | Hasta |
| --- | --- | --- |
| 1: WF01 | Usar ubicación | 2: WF02 |
| 2: WF02 | Autorizar o elegir mapa | 3: WF03 |
| 3: WF03 | Ver alternativa | 4: WF04 |
| 4: WF04 | Iniciar recorrido | 5: WF05 |
| 2: WF02 | Sin permiso: elegir mapa | 1: WF01 |


Los datos inválidos permanecen en WF01. Sin alternativas se muestra WF15; un fallo cartográfico abre WF14. UNKNOWN permite comparar tiempo y distancia.


#### 6.4.2.2. UG02 · Evaluar una alerta y cambiar la ruta


**User goal:** Evaluar una alerta y cambiar la ruta.


**Persona e historias:** Estudiante o trabajador con recorrido activo · US10–US11.


<p align="center">
  <img src="assets/wireflow_alertas.png" alt="UG02 · Evaluar una alerta y cambiar la ruta" width="100%">
</p>


| Desde | Acción | Hasta |
| --- | --- | --- |
| 1: WF05 | Incidente pertinente | 2: WF06 |
| 2: WF06 | Buscar alternativa | 3: WF07 |
| 3: WF07 | Confirmar nueva ruta | 5: WF05 |
| 3: WF07 | Sin alternativa | 4: WF15 |
| 2: WF06 | Continuar ruta vigente | 5: WF05 |


El nuevo estado de WF05 usa una versión de ruta incrementada. La reconexión entrega solo alertas vigentes. Sin permiso o avance actualizado se informa que las alertas están pausadas.


#### 6.4.2.3. UG03 · Reportar un incidente observado


**User goal:** Reportar un incidente observado.


**Persona e historias:** Estudiante o trabajador colaborador · US13–US15.


<p align="center">
  <img src="assets/wireflow_reportes.png" alt="UG03 · Reportar un incidente observado" width="100%">
</p>


| Desde | Acción | Hasta |
| --- | --- | --- |
| 1: WF08 | Completar datos | 2: WF09 |
| 2: WF09 | Confirmar ubicación | 3: WF16 |
| 3: WF16 | Enviar reporte | 4: WF10 |
| 4: WF10 | Consultar estado | 5: WF11 |
| 3: WF16 | Corregir información | 1: WF08 |


Un error de validación conserva el formulario. Un fallo de envío conserva el borrador en memoria y reutiliza la clave idempotente al reintentar. WF10 aparece solo tras confirmación del servidor.


#### 6.4.2.4. UG04 · Conocer el resultado de un reporte


**User goal:** Conocer el resultado de un reporte.


**Persona e historias:** Usuario de la sesión propietaria · US16.


<p align="center">
  <img src="assets/wireflow_estado.png" alt="UG04 · Conocer el resultado de un reporte" width="100%">
</p>


| Desde | Acción | Hasta |
| --- | --- | --- |
| 1: WF11 | Abrir reporte pendiente | 2: WF10 |
| 2: WF10 | Actualizar estado | 3: WF11 |


El segundo WF11 representa el estado actualizado: publicado no verificado, vinculado o rechazado con explicación. Una sesión distinta no puede consultar el reporte.


#### 6.4.2.5. UG05 · Reutilizar o borrar una consulta anterior


**User goal:** Reutilizar o borrar una consulta anterior.


**Persona e historias:** Estudiante o trabajador · US12 y TS04.


<p align="center">
  <img src="assets/wireflow_historial.png" alt="UG05 · Reutilizar o borrar una consulta anterior" width="100%">
</p>


| Desde | Acción | Hasta |
| --- | --- | --- |
| 1: WF12 | Volver a consultar | 2: WF03 |
| 2: WF03 | Revisar datos actuales | 3: WF04 |
| 1: WF12 | Borrar y confirmar | 4: WF12 |


La reutilización genera una nueva consulta; no reactiva una evaluación antigua. El último WF12 representa el estado vacío. Sin consentimiento no se guarda historial.


#### 6.4.2.6. UG06 · Cambiar autorización y preferencias


**User goal:** Cambiar autorización y preferencias.


**Persona e historias:** Cualquier usuario · TS04.


<p align="center">
  <img src="assets/wireflow_privacidad.png" alt="UG06 · Cambiar autorización y preferencias" width="100%">
</p>


| Desde | Acción | Hasta |
| --- | --- | --- |
| 1: WF13 | Dejar de usar ubicación | 2: WF05 |
| 2: WF05 | Alertas pausadas / cerrar | 3: WF13 |
| 3: WF13 | Elegir origen en mapa | 4: WF01 |


La preferencia interna detiene el uso de ubicación y cierra el recorrido; la revocación del permiso del navegador se gestiona desde sus ajustes. El historial puede borrarse por separado.


## Relación del diseño UX con ADD y DDD


| Necesidad o driver | Diseño de interacción | Contexto responsable |
| --- | --- | --- |
| Comparar criterios / US07 | Tarjetas homogéneas con tiempo, distancia y estimación. | Route Planning + Risk Assessment. |
| Incertidumbre / QA04 | UNKNOWN con causa, cobertura y vigencia; no se presenta como ruta de menor riesgo. | Risk Assessment. |
| Alertas pertinentes / QA02 | Estado activo, alerta contextual, decisión de recálculo y estado de pausa. | Journey Alerts + Route Planning. |
| Contribución comunitaria / US13–US16 | Formulario por etapas y estados pendiente/publicado/vinculado/rechazado. | Incident Reporting. |
| Privacidad / QA05 | Permiso opcional, alternativa manual, cierre explícito e historial local optativo. | Gateway y autorización en cada servicio; historial en navegador. |
| Fallo externo / QA03 | Reintento con puntos conservados y acceso a reportes independientes. | Route Planning y adaptador cartográfico. |
| Integridad / QA06 | Envío único percibido pese a retry; una alerta lógica con ID estable. | Outbox/inbox de los servicios y claves idempotentes. |

