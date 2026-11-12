workspace "VSafe - Arquitectura implementada" "Estado comprobado al 12 de noviembre de 2026: Cloudflare Pages, Railway, Mapbox y Sepolia; modelo ML pendiente de validacion real." {
    !impliedRelationships false

    model {
        estudiante = person "Estudiante universitario" "Planifica recorridos, consulta incidentes y recibe alertas."
        trabajador = person "Trabajador urbano" "Compara recorridos y aporta reportes desde una sesion anonima."
        equipo = person "Equipo de desarrollo" "Mantiene codigo, documentacion y configuracion del despliegue."

        github = softwareSystem "GitHub" "Repositorios Informe, Microservices, WebApp y landing-page." "Externo"
        mapbox = softwareSystem "Mapbox Directions API" "Calcula recorridos peatonales y alternativas disponibles." "Externo"
        osm = softwareSystem "OpenStreetMap" "Entrega las teselas del mapa utilizado por Leaflet." "Externo"
        alchemy = softwareSystem "Alchemy RPC" "Acceso JSON-RPC a Ethereum Sepolia para transacciones y consultas del contrato." "Externo"

        vsafe = softwareSystem "VSafe" "Navegacion peatonal con contexto, reportes y alertas. La estimacion ML real permanece UNKNOWN hasta validar el modelo." {
            landing = container "Landing Page" "Presenta VSafe y enlaza a WebApp." "HTML, CSS, JavaScript, Vite" {
                url "https://landing-page-5hy.pages.dev/"
            }
            web = container "WebApp" "SPA por features y Clean Architecture. Mapas, recorridos, reportes y permisos." "Vue, TypeScript, PrimeVue, Leaflet" {
                url "https://vsafe-web.pages.dev/"
            }
            history = container "Historial y preferencias locales" "Consultas optativas, consentimiento e idioma. Permanecen en el navegador." "localStorage" "BaseDatos"
            proxy = container "Proxy de API" "Reenvia /api al Gateway y conserva cookies y streaming SSE." "Cloudflare Pages Functions, TypeScript"
            gateway = container "API Gateway" "Sesion anonima JWT, CSRF, origenes permitidos, limites y enrutamiento. Swagger/OpenAPI." "NestJS, TypeScript" {
                url "https://gateway-production-61ce8b27.up.railway.app/docs"
            }

            routes = container "Route Planning" "Gestiona alternativas y recorridos. Consulta Mapbox y Risk Assessment." "NestJS, TypeScript" {
                routeApi = component "PlanningController" "Endpoints de rutas, recorridos y consulta interna del trayecto activo." "NestJS - Interface"
                routeApp = component "PlanningService" "Coordina busqueda, comparacion, progreso y cierre." "Application"
                routeDomain = component "JourneyAggregate / JourneyPolicy" "Reglas de versiones, estados, avance y geometria restante." "Domain"
                routeRepo = component "PgJourneys" "Persistencia privada y escritura transaccional del outbox." "Infrastructure - PostgreSQL"
                routeMapbox = component "MapboxProvider" "Directions walking, timeout y circuit breaker." "Infrastructure - HTTPS"
                routeRisk = component "HttpRiskAdapter" "Solicita evaluaciones mediante identidad interna firmada." "Infrastructure - HTTP"
                routeEvents = component "EventRuntime" "Publica el outbox con confirmaciones del broker." "Infrastructure - RabbitMQ"
            }
            risk = container "Risk Assessment" "Evalua evidencia y cobertura. En modo real devuelve UNKNOWN / MODEL_NOT_VALIDATED con el modelo actual." "NestJS, TypeScript, ONNX Runtime" "Emergente" {
                riskApi = component "RiskController" "Endpoint interno para evaluar hasta tres geometrías." "NestJS - Interface"
                riskApp = component "RiskService" "Combina evidencia, metadatos del modelo y reglas de abstencion." "Application"
                riskDomain = component "RiskPolicy / RiskAssessmentAggregate" "Umbrales, vigencia, cobertura y consistencia de la evaluacion." "Domain"
                riskRepo = component "PgEvidence" "Proyeccion geoespacial, checkpoints y reconciliacion de incidentes." "Infrastructure - PostGIS"
                riskOnnx = component "OnnxInference" "Inferencia local CPU con risk-demo.onnx. Datos sinteticos; pendiente de validacion real." "ONNX Runtime - IA/ML" "Emergente"
                riskEvents = component "EventRuntime" "Consume eventos y delega la actualizacion de la proyeccion." "Infrastructure - RabbitMQ"
            }
            reports = container "Incident Reporting" "Registra, deduplica y expira incidentes. Procesa la evidencia de integridad en blockchain." "NestJS, TypeScript, ethers" {
                reportApi = component "ReportsController" "Reportes propios, incidentes publicables, auditoria y snapshot interno." "NestJS - Interface"
                reportApp = component "ReportService" "Coordina validacion, consulta y verificacion de reportes." "Application"
                reportDomain = component "IncidentAggregate / ReportPolicy" "Publicacion, duplicados, vigencia y aproximacion de coordenadas." "Domain"
                reportRepo = component "PgReports" "Incidentes, idempotencia, outbox y registros pendientes de auditoria." "Infrastructure - PostGIS"
                reportAudit = component "BlockchainAudit" "Ancla compromisos con sal y contrasta su integridad. No acredita la veracidad del incidente." "ethers, JSON-RPC" "Emergente"
                reportEvents = component "EventRuntime" "Publica incidentes, expiraciones y watermarks desde el outbox." "Infrastructure - RabbitMQ"
            }
            alerts = container "Journey Alerts" "Evalua incidentes cercanos al trayecto restante y entrega alertas SSE." "NestJS, TypeScript" {
                alertApi = component "AlertsController" "Abre el stream SSE y recibe confirmaciones de alertas." "NestJS - Interface"
                alertApp = component "AlertsService" "Coordina refresco, consulta y confirmacion de alertas." "Application"
                alertDomain = component "AlertPolicy / JourneyAlertAggregate" "Relevancia espacial, vigencia y deduplicacion." "Domain"
                alertRepo = component "PgAlerts" "Proyecciones, trayectos activos, alertas e inbox." "Infrastructure - PostGIS"
                alertEvents = component "EventRuntime" "Consume eventos de recorridos e incidentes con reintentos." "Infrastructure - RabbitMQ"
            }

            broker = container "Broker de eventos" "Exchange topic, colas durables, reintentos y colas de errores." "RabbitMQ 4, AMQP" "Cola"
            routesDb = container "route_planning_db" "Recorridos temporales, opciones, idempotencia y outbox. Rol vsafe_routes." "PostgreSQL / PostGIS" "BaseDatos"
            riskDb = container "risk_assessment_db" "Evidencia proyectada, inbox, checkpoints y metadatos. Rol vsafe_risk." "PostgreSQL / PostGIS" "BaseDatos"
            reportsDb = container "incident_reporting_db" "Incidentes, idempotencia, outbox y audit_records. Rol vsafe_incidents." "PostgreSQL / PostGIS" "BaseDatos"
            alertsDb = container "journey_alerts_db" "Proyecciones, trayectos, alertas e inbox. Rol vsafe_alerts." "PostgreSQL / PostGIS" "BaseDatos"
            contract = container "IncidentAudit" "Contrato de VSafe: conserva compromisos opacos por version; escritura restringida al writer." "Solidity / EVM - Ethereum Sepolia" "Emergente" {
                url "https://sepolia.etherscan.io/address/0xE775Fd6A4Ee1CA64c99b672C8e7aA0bad8272B30"
            }
        }

        // Relaciones de contexto y entorno de desarrollo.
        estudiante -> vsafe "Consulta recorridos, reporta y recibe alertas"
        trabajador -> vsafe "Consulta recorridos, reporta y recibe alertas"
        equipo -> vsafe "Desarrolla y configura el despliegue"
        equipo -> github "Versiona y revisa codigo y documentacion" "Git / HTTPS"
        vsafe -> mapbox "Obtiene rutas peatonales" "HTTPS"
        vsafe -> osm "Obtiene cartografia base" "HTTPS"
        vsafe -> alchemy "Ancla y verifica integridad en Sepolia" "HTTPS / JSON-RPC"

        // Relaciones entre aplicaciones y almacenes.
        estudiante -> landing "Consulta la propuesta" "HTTPS"
        trabajador -> landing "Consulta la propuesta" "HTTPS"
        estudiante -> web "Utiliza la aplicacion" "HTTPS"
        trabajador -> web "Utiliza la aplicacion" "HTTPS"
        landing -> web "Enlaza al acceso de la aplicacion" "HTTPS"
        web -> history "Guarda y consulta con consentimiento" "Web Storage API"
        web -> osm "Solicita teselas del mapa" "HTTPS"
        web -> proxy "Consulta API y recibe SSE; cookie y CSRF" "HTTPS / JSON / SSE"
        proxy -> gateway "Retransmite solicitudes, cookies y streaming" "HTTPS / JSON / SSE"
        gateway -> routes "Enruta rutas y recorridos" "HTTP privado / JWT"
        gateway -> reports "Enruta reportes, incidentes y auditoria" "HTTP privado / JWT"
        gateway -> alerts "Abre SSE y confirma alertas" "HTTP privado / JWT / SSE"
        routes -> risk "Solicita evaluaciones de alternativas" "HTTP privado / JWT"
        routes -> mapbox "Consulta Directions con perfil walking" "HTTPS"
        risk -> reports "Reconcilia snapshot y watermark" "HTTP privado / JWT"
        alerts -> reports "Reconcilia snapshot y watermark" "HTTP privado / JWT"
        alerts -> routes "Obtiene el trayecto activo restante" "HTTP privado / JWT"
        routes -> routesDb "Lee y escribe con rol exclusivo" "PostgreSQL"
        risk -> riskDb "Lee y escribe con rol exclusivo" "PostgreSQL"
        reports -> reportsDb "Lee y escribe con rol exclusivo" "PostgreSQL"
        alerts -> alertsDb "Lee y escribe con rol exclusivo" "PostgreSQL"
        routes -> broker "Publica JourneyStarted, JourneyRouteChanged y JourneyClosed" "AMQP / outbox"
        reports -> broker "Publica IncidentPublished, IncidentExpired e IncidentWatermark" "AMQP / outbox"
        broker -> risk "Entrega eventos de incidentes" "AMQP / inbox"
        broker -> alerts "Entrega eventos de recorridos e incidentes" "AMQP / inbox"
        reports -> alchemy "Firma transacciones y consulta compromisos" "HTTPS / JSON-RPC"
        alchemy -> contract "Envia transacciones y eth_call a Sepolia" "Ethereum JSON-RPC / EVM"

        // Componentes: Route Planning.
        gateway -> routeApi "Invoca operaciones de rutas y recorridos" "HTTP / JWT"
        routeApi -> routeApp "Delega casos de uso"
        routeApp -> routeDomain "Valida progreso y reglas del recorrido"
        routeApp -> routeRepo "Gestiona recorridos y opciones"
        routeRepo -> routeDomain "Aplica reglas del agregado"
        routeApp -> routeMapbox "Solicita alternativas"
        routeApp -> routeRisk "Solicita evaluaciones"
        routeRepo -> routesDb "Persiste datos y outbox" "SQL"
        routeMapbox -> mapbox "Calcula recorridos peatonales" "HTTPS"
        routeRisk -> risk "Evalua geometrías" "HTTP / JWT"
        routeEvents -> routesDb "Lee el outbox y confirma publicacion" "SQL"
        routeEvents -> broker "Publica eventos durables" "AMQP"

        // Componentes: Risk Assessment.
        routes -> riskApi "Solicita evaluaciones internas" "HTTP / JWT"
        riskApi -> riskApp "Delega evaluacion"
        riskApp -> riskDomain "Aplica politicas de estimacion y abstencion"
        riskApp -> riskRepo "Consulta evidencia y guarda metadatos"
        riskApp -> riskOnnx "Consulta metadatos; infiere solo cuando procede" "Llamada local"
        riskRepo -> riskDb "Mantiene evidencia, inbox y checkpoints" "SQL / PostGIS"
        riskRepo -> reports "Reconcilia snapshot consistente" "HTTP / JWT"
        broker -> riskEvents "Entrega eventos de incidentes" "AMQP"
        riskEvents -> riskRepo "Aplica eventos y reconciliacion"
        riskEvents -> riskDb "Consulta su outbox tecnico" "SQL"

        // Componentes: Incident Reporting.
        gateway -> reportApi "Invoca reportes y auditoria" "HTTP / JWT"
        reportApi -> reportApp "Delega casos de uso"
        reportApp -> reportDomain "Valida tiempo y cobertura"
        reportApp -> reportRepo "Crea y consulta reportes"
        reportApp -> reportAudit "Consulta la verificacion de integridad"
        reportRepo -> reportDomain "Aplica reglas del incidente"
        reportRepo -> reportsDb "Escribe incidentes, outbox y auditorias pendientes" "SQL / PostGIS"
        reportAudit -> reportsDb "Lee pendientes y conserva recibos" "SQL"
        reportAudit -> alchemy "Ancla y consulta compromisos" "HTTPS / JSON-RPC"
        reportEvents -> reportsDb "Lee y confirma el outbox" "SQL"
        reportEvents -> broker "Publica eventos de incidentes" "AMQP"

        // Componentes: Journey Alerts.
        gateway -> alertApi "Abre SSE y confirma recepcion" "HTTP / JWT / SSE"
        alertApi -> alertApp "Consulta y confirma alertas"
        alertApp -> alertRepo "Refresca proyecciones y obtiene alertas"
        alertRepo -> alertDomain "Evalua relevancia y deduplicacion"
        alertRepo -> alertsDb "Gestiona proyecciones, alertas e inbox" "SQL / PostGIS"
        alertRepo -> routes "Consulta trayecto activo restante" "HTTP / JWT"
        alertRepo -> reports "Reconcilia snapshot de incidentes" "HTTP / JWT"
        broker -> alertEvents "Entrega eventos de recorridos e incidentes" "AMQP"
        alertEvents -> alertRepo "Aplica eventos y refresca proyecciones"
        alertEvents -> alertsDb "Consulta su outbox tecnico" "SQL"

        produccion = deploymentEnvironment "Produccion" {
            deploymentNode "Dispositivo del usuario" "Ejecucion de la SPA y almacenamiento local." "Navegador web" {
                webRuntime = containerInstance web
                containerInstance history
            }
            deploymentNode "Cloudflare" "Distribucion de archivos y proxy de API." "Cloudflare Pages" {
                deploymentNode "Pages - landing-page-5hy" "Sitio estatico publicado." "CDN / HTTPS" {
                    containerInstance landing
                }
                deploymentNode "Pages - vsafe-web" "Distribuye la SPA y ejecuta el proxy /api." "CDN / Pages Functions" {
                    webAssets = infrastructureNode "Archivos de WebApp" "HTML, JavaScript y CSS descargados por el navegador." "Cloudflare CDN"
                    containerInstance proxy
                }
            }
            deploymentNode "Railway - production" "Servicios independientes y red privada. Sin alta disponibilidad acreditada." "Railway / Railpack" {
                deploymentNode "gateway" "Unica API con dominio publico HTTPS." "Node.js 24 / puerto 8080" {
                    containerInstance gateway
                }
                deploymentNode "route-planning" "Microservicio privado." "Node.js 24 / puerto 8080" {
                    containerInstance routes
                }
                deploymentNode "risk-assessment" "ONNX Runtime y artefacto del modelo en el mismo proceso." "Node.js 24 / ONNX Runtime CPU" {
                    containerInstance risk
                }
                deploymentNode "incident-reporting" "Microservicio privado con worker de anclaje en el proceso." "Node.js 24 / ethers" {
                    containerInstance reports
                }
                deploymentNode "journey-alerts" "Microservicio privado con consumidores y SSE." "Node.js 24 / puerto 8080" {
                    containerInstance alerts
                }
                deploymentNode "PostGIS - instancia compartida" "Un volumen persistente; cuatro bases y cuatro roles exclusivos." "PostgreSQL / PostGIS / puerto 5432" {
                    containerInstance routesDb
                    containerInstance riskDb
                    containerInstance reportsDb
                    containerInstance alertsDb
                }
                deploymentNode "rabbitmq" "Nodo estable y volumen en /var/lib/rabbitmq; AMQP privado." "RabbitMQ 4 / puerto 5672" {
                    containerInstance broker
                }
            }
            deploymentNode "Mapbox Cloud" "Proveedor de rutas peatonales." "Directions API / HTTPS" {
                softwareSystemInstance mapbox
            }
            deploymentNode "OpenStreetMap" "Proveedor de teselas para Leaflet." "HTTPS" {
                softwareSystemInstance osm
            }
            deploymentNode "Alchemy Cloud" "Pasarela RPC a Sepolia." "HTTPS / JSON-RPC" {
                softwareSystemInstance alchemy
            }
            deploymentNode "Ethereum Sepolia" "Red publica de pruebas; no es Ethereum Mainnet." "EVM / chain ID 11155111" {
                containerInstance contract
            }
            webRuntime -> webAssets "Descarga archivos de la SPA" "HTTPS"
        }
    }

    views {
        systemLandscape "VSafe-Landscape" {
            title "VSafe - System Landscape"
            include estudiante trabajador equipo vsafe github mapbox osm alchemy
            autoLayout lr
        }
        systemContext vsafe "VSafe-Context" {
            title "VSafe - System Context"
            include estudiante trabajador vsafe mapbox osm alchemy
            autoLayout lr
        }
        container vsafe "VSafe-Containers" {
            title "VSafe - Containers logicos"
            include *
            exclude equipo github
            autoLayout lr
        }
        deployment * produccion "VSafe-Deployment" {
            title "VSafe - Despliegue actual en Cloudflare, Railway y Sepolia"
            include *
            autoLayout lr
        }
        component routes "VSafe-RoutePlanning-Components" {
            title "Route Planning - Componentes"
            include *
            autoLayout lr
        }
        component risk "VSafe-RiskAssessment-Components" {
            title "Risk Assessment - Componentes e IA/ML"
            include *
            autoLayout lr
        }
        component reports "VSafe-IncidentReporting-Components" {
            title "Incident Reporting - Componentes y blockchain"
            include *
            include contract
            autoLayout lr
        }
        component alerts "VSafe-JourneyAlerts-Components" {
            title "Journey Alerts - Componentes"
            include *
            autoLayout lr
        }
        styles {
            element "Person" {
                shape Person
                background #084c61
                color #ffffff
            }
            element "Software System" {
                background #0b6972
                color #ffffff
            }
            element "Container" {
                background #168b91
                color #ffffff
            }
            element "Component" {
                background #d7eeee
                color #163944
            }
            element "Externo" {
                background #667582
                color #ffffff
            }
            element "BaseDatos" {
                shape Cylinder
                background #355c7d
                color #ffffff
            }
            element "Cola" {
                shape Pipe
                background #c66b2b
                color #ffffff
            }
            element "Emergente" {
                background #7653a5
                color #ffffff
            }
            element "Deployment Node" {
                background #f2f6f7
                color #243944
                stroke #8097a0
            }
            relationship "Relationship" {
                color #526875
                fontSize 18
            }
        }
    }
}
