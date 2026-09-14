# Capítulo III: Requirements Specification

Este capítulo especifica los requisitos de VSafe a partir del problema, los segmentos objetivo, las suposiciones y las hipótesis descritas en el capítulo I. La propuesta busca que las personas que se desplazan por la ciudad puedan comparar rutas considerando tiempo, distancia y nivel de riesgo estimado, consultar incidentes relevantes, recibir alertas durante el recorrido y aportar información a la comunidad. La especificación mantiene la trazabilidad entre los escenarios futuros, las historias de usuario, los objetivos de negocio y el Product Backlog.

## Contenido

- [3.1 To-Be Scenario Mapping](#31-to-be-scenario-mapping)
  - [3.1.1 Estudiante que se desplaza diariamente](#311-estudiante-que-se-desplaza-diariamente)
  - [3.1.2 Trabajador que transita por zonas desconocidas o en horario nocturno](#312-trabajador-que-transita-por-zonas-desconocidas-o-en-horario-nocturno)
- [3.2 User Stories](#32-user-stories)
  - [3.2.1 Epics](#321-epics)
  - [3.2.2 Historias de usuario y técnicas](#322-historias-de-usuario-y-técnicas)
- [3.3 Impact Mapping](#33-impact-mapping)
- [3.4 Product Backlog](#34-product-backlog)

## 3.1 To-Be Scenario Mapping

Los To-Be Scenario Maps representan la experiencia esperada después de incorporar VSafe al desplazamiento cotidiano. Para mantener correspondencia con los segmentos identificados, se consideran dos perfiles representativos: una persona que realiza recorridos frecuentes por estudio y una persona que se moviliza por trabajo, en ocasiones de noche o por zonas que no conoce. En ambos casos, el cambio principal consiste en pasar de elegir una ruta únicamente por tiempo o distancia a tomar una decisión informada mediante un nivel de riesgo estimado, incidentes cercanos y alertas contextualizadas.

### 3.1.1 Estudiante que se desplaza diariamente

**Objetivo del escenario:** llegar a la universidad mediante una ruta que mantenga un equilibrio aceptable entre duración y nivel de riesgo estimado.

| Dimensión | 1 Planificar el recorrido | 2 Comparar alternativas | 3 Iniciar el trayecto | 4 Responder a una alerta | 5 Contribuir con la comunidad |
|---|---|---|---|---|---|
| **Doing** | Ingresa el punto de origen y la universidad como destino. | Revisa las rutas propuestas y compara tiempo, distancia, incidentes y riesgo estimado. | Selecciona la alternativa que considera más conveniente y comienza el recorrido. | Consulta el incidente detectado y evalúa una ruta alternativa. | Registra un incidente observado, indicando su tipo y ubicación. |
| **Thinking** | “Quiero llegar a tiempo sin pasar por una zona que considero riesgosa”. | “¿Cuánto tiempo adicional implica la alternativa con menor riesgo?”. | “Sé por qué elegí esta ruta y qué debo esperar durante el trayecto”. | “Necesito saber si el incidente afecta realmente mi recorrido”. | “Mi reporte puede ayudar a otras personas que transiten por aquí”. |
| **Feeling** | Preocupación moderada por el trayecto. | Mayor control al disponer de información comparable. | Confianza prudente durante el desplazamiento. | Atención y capacidad de reacción ante el cambio. | Utilidad y participación comunitaria. |

**Cambio frente a la situación actual:** la persona deja de depender únicamente de recomendaciones genéricas o de su conocimiento previo de la zona. VSafe centraliza la información necesaria para comparar alternativas y reaccionar ante incidentes que puedan afectar el recorrido.

### 3.1.2 Trabajador que transita por zonas desconocidas o en horario nocturno

**Objetivo del escenario:** completar un desplazamiento laboral con información actualizada sobre los posibles riesgos de las zonas atravesadas.

| Dimensión | 1 Definir el destino | 2 Evaluar el entorno | 3 Elegir una ruta | 4 Mantenerse informado | 5 Finalizar y revisar |
|---|---|---|---|---|---|
| **Doing** | Utiliza su ubicación actual o registra manualmente un origen y un destino. | Observa los incidentes próximos y los niveles de riesgo estimados de las alternativas. | Compara la ruta más rápida con una ruta de menor riesgo y selecciona una. | Recibe alertas relevantes y solicita un nuevo cálculo cuando cambian las condiciones. | Finaliza el recorrido y consulta la ruta realizada en su historial. |
| **Thinking** | “No conozco bien esta zona y necesito orientación antes de avanzar”. | “Quiero entender qué información justifica el nivel de riesgo mostrado”. | “Puedo aceptar algunos minutos adicionales si la alternativa reduce mi exposición”. | “Si aparece un incidente nuevo, necesito una opción viable para continuar”. | “Quiero recordar qué recorrido funcionó mejor para una situación similar”. |
| **Feeling** | Incertidumbre inicial. | Información suficiente para evaluar opciones. | Decisión consciente y mayor sensación de control. | Acompañamiento durante el desplazamiento. | Tranquilidad al completar el trayecto. |

**Cambio frente a la situación actual:** la planificación deja de ser una decisión estática tomada antes de salir. VSafe acompaña el recorrido con información contextual, permite reconsiderar la ruta y conserva un historial útil para futuros desplazamientos.

## 3.2 User Stories

Las historias de usuario convierten las necesidades identificadas en capacidades verificables para el Landing Page y la aplicación de VSafe. También se incluyen historias técnicas para los servicios que calculan el riesgo, consultan incidentes y protegen los datos de ubicación. Los criterios de aceptación están redactados en formato Gherkin y evitan depender de una implementación visual específica.

### 3.2.1 Epics

| Epic ID | Título | Descripción |
|---|---|---|
| **EP01** | Descubrimiento de VSafe | Comunicar la propuesta de valor y conducir a los visitantes desde el Landing Page hacia la experiencia principal. |
| **EP02** | Planificación de rutas informadas | Permitir que las personas definan un recorrido, comparen alternativas y elijan considerando tiempo, distancia y riesgo estimado. |
| **EP03** | Acompañamiento durante el recorrido | Informar sobre incidentes relevantes y ofrecer alternativas cuando cambien las condiciones del trayecto. |
| **EP04** | Colaboración comunitaria | Facilitar el registro de incidentes y aprovechar los aportes de la comunidad para mantener actualizada la información. |
| **EP05** | Inteligencia y confianza de la plataforma | Proveer capacidades técnicas para calcular el riesgo, procesar información geoespacial, validar reportes y tratar responsablemente los datos de ubicación. |

### 3.2.2 Historias de usuario y técnicas

| Epic / User Story ID | Título | Descripción | Criterios de aceptación | Relacionado con |
|---|---|---|---|---|
| **EP01** | Descubrimiento de VSafe | Como visitante, deseo conocer la propuesta de VSafe para decidir si puede ayudarme en mis desplazamientos. | No aplica a nivel de Epic. | — |
| **US01** | Comprender la propuesta de valor | Como visitante, deseo conocer qué problema resuelve VSafe para evaluar su utilidad. | **Escenario 1:** Dado que el visitante accede al Landing Page, cuando consulta la presentación del producto, entonces comprende que VSafe compara rutas mediante tiempo, distancia y riesgo estimado.<br><br>**Escenario 2:** Dado que el visitante revisa la propuesta, cuando consulta los beneficios, entonces identifica la visualización de incidentes, las alertas y los reportes comunitarios. | EP01 |
| **US02** | Conocer las capacidades principales | Como visitante, deseo revisar las principales capacidades de VSafe para entender cómo puede acompañar mi recorrido. | **Escenario 1:** Dado que el visitante explora el contenido informativo, cuando revisa las capacidades, entonces encuentra la búsqueda de rutas, la comparación de alternativas, los incidentes y las alertas.<br><br>**Escenario 2:** Dado que el visitante necesita más contexto, cuando consulta una capacidad, entonces recibe una explicación coherente con el propósito de seguridad urbana de VSafe. | EP01 |
| **US03** | Acceder a la aplicación | Como visitante, deseo ingresar a la aplicación desde el Landing Page para comenzar a planificar un recorrido. | **Escenario 1:** Dado que el visitante decide utilizar VSafe, cuando solicita comenzar, entonces accede al punto de entrada de la aplicación.<br><br>**Escenario 2:** Dado que el acceso no está disponible, cuando el visitante intenta continuar, entonces recibe información clara sobre la indisponibilidad. | EP01 |
| **EP02** | Planificación de rutas informadas | Como usuario, deseo comparar rutas con información de riesgo para elegir una alternativa adecuada a mis necesidades. | No aplica a nivel de Epic. | — |
| **US04** | Definir origen y destino | Como usuario, deseo indicar mi origen y destino para solicitar alternativas de recorrido. | **Escenario 1:** Dado que el usuario proporciona un origen y un destino válidos, cuando solicita rutas, entonces el sistema procesa ambos puntos.<br><br>**Escenario 2:** Dado que falta uno de los puntos o no puede identificarse, cuando el usuario solicita rutas, entonces el sistema informa qué dato debe corregirse. | EP02 |
| **US05** | Utilizar la ubicación actual | Como usuario, deseo utilizar mi ubicación actual como origen para iniciar una búsqueda con menor esfuerzo. | **Escenario 1:** Dado que el usuario autoriza el acceso a su ubicación, cuando selecciona usarla como origen, entonces el sistema registra la posición disponible.<br><br>**Escenario 2:** Dado que el usuario no autoriza o no dispone de ubicación, cuando intenta utilizarla, entonces el sistema permite ingresar el origen manualmente. | EP02 |
| **US06** | Visualizar rutas alternativas | Como usuario, deseo recibir diferentes alternativas de ruta para no depender de una única opción. | **Escenario 1:** Dado que existen recorridos disponibles, cuando finaliza el cálculo, entonces el sistema presenta más de una alternativa cuando las condiciones lo permiten.<br><br>**Escenario 2:** Dado que solo existe una alternativa válida, cuando finaliza el cálculo, entonces el sistema presenta esa ruta e informa la limitación. | EP02 |
| **US07** | Comparar tiempo distancia y riesgo | Como usuario, deseo comparar las rutas por duración, distancia y nivel de riesgo estimado para tomar una decisión informada. | **Escenario 1:** Dado que se obtuvieron rutas alternativas, cuando el usuario las compara, entonces cada alternativa presenta duración, distancia y riesgo estimado bajo criterios consistentes.<br><br>**Escenario 2:** Dado que falta información suficiente para estimar el riesgo, cuando se muestra la ruta afectada, entonces el sistema comunica la incertidumbre sin presentar el valor como concluyente. | EP02 |
| **US08** | Seleccionar una ruta | Como usuario, deseo elegir una de las alternativas para iniciar el recorrido que mejor se adapte a mis prioridades. | **Escenario 1:** Dado que el usuario revisó las alternativas, cuando selecciona una ruta, entonces el sistema la establece como recorrido activo.<br><br>**Escenario 2:** Dado que cambian los datos antes del inicio, cuando la ruta seleccionada deja de estar disponible, entonces el sistema solicita elegir una alternativa vigente. | EP02 |
| **US09** | Consultar incidentes del recorrido | Como usuario, deseo conocer los incidentes cercanos a las rutas para comprender el contexto del riesgo estimado. | **Escenario 1:** Dado que existen incidentes relevantes, cuando el usuario consulta una ruta, entonces el sistema presenta su tipo, ubicación aproximada y vigencia.<br><br>**Escenario 2:** Dado que no existen incidentes relevantes registrados, cuando el usuario consulta la ruta, entonces el sistema comunica que no se encontraron reportes aplicables sin afirmar que la zona carece de riesgo. | EP02 |
| **EP03** | Acompañamiento durante el recorrido | Como usuario en desplazamiento, deseo recibir información relevante para reaccionar ante cambios que afecten la ruta seleccionada. | No aplica a nivel de Epic. | — |
| **US10** | Recibir alertas de incidentes | Como usuario, deseo recibir alertas sobre incidentes relevantes cercanos a mi ruta para evaluar oportunamente si debo modificarla. | **Escenario 1:** Dado que existe un recorrido activo, cuando aparece un incidente relevante dentro del área evaluada, entonces el sistema informa al usuario sobre la situación.<br><br>**Escenario 2:** Dado que un incidente no afecta el recorrido activo, cuando es procesado, entonces el sistema evita generar una alerta innecesaria. | EP03 |
| **US11** | Solicitar una ruta alternativa | Como usuario, deseo recalcular mi recorrido después de una alerta para continuar por una alternativa disponible. | **Escenario 1:** Dado que el usuario recibe una alerta, cuando solicita recalcular, entonces el sistema evalúa rutas vigentes desde su posición disponible.<br><br>**Escenario 2:** Dado que no existe una alternativa, cuando finaliza el recálculo, entonces el sistema informa la situación sin ocultar el incidente detectado. | EP03 |
| **US12** | Consultar recorridos anteriores | Como usuario, deseo revisar mis rutas consultadas anteriormente para reutilizar información en desplazamientos similares. | **Escenario 1:** Dado que existen consultas anteriores, cuando el usuario accede a su historial, entonces el sistema presenta los datos esenciales de cada recorrido.<br><br>**Escenario 2:** Dado que no existen consultas anteriores, cuando el usuario accede al historial, entonces el sistema informa que todavía no hay recorridos registrados. | EP03 |
| **EP04** | Colaboración comunitaria | Como miembro de la comunidad, deseo registrar incidentes para aportar información útil a otros usuarios. | No aplica a nivel de Epic. | — |
| **US13** | Registrar un incidente | Como usuario, deseo reportar un incidente observado para contribuir con información sobre el entorno urbano. | **Escenario 1:** Dado que el usuario dispone de los datos requeridos, cuando envía el reporte, entonces el sistema lo registra para su procesamiento.<br><br>**Escenario 2:** Dado que falta información requerida, cuando el usuario intenta enviar el reporte, entonces el sistema identifica los datos pendientes. | EP04 |
| **US14** | Clasificar el incidente | Como usuario, deseo indicar el tipo de incidente para que otras personas comprendan la situación reportada. | **Escenario 1:** Dado que el usuario crea un reporte, cuando selecciona una categoría válida, entonces el sistema asocia esa categoría al incidente.<br><br>**Escenario 2:** Dado que ninguna categoría representa lo ocurrido, cuando el usuario elige la opción correspondiente, entonces puede proporcionar una descripción complementaria. | EP04 |
| **US15** | Confirmar la ubicación del reporte | Como usuario, deseo confirmar la ubicación aproximada del incidente para evitar que el reporte afecte zonas incorrectas. | **Escenario 1:** Dado que existe una ubicación disponible, cuando el usuario la confirma, entonces el sistema la asocia al reporte.<br><br>**Escenario 2:** Dado que la ubicación detectada no corresponde al incidente, cuando el usuario la corrige, entonces el sistema conserva la ubicación confirmada. | EP04 |
| **US16** | Conocer el estado del reporte | Como usuario, deseo conocer el estado de mis reportes para saber si fueron incorporados a la información de la plataforma. | **Escenario 1:** Dado que el usuario registró un incidente, cuando consulta sus reportes, entonces el sistema muestra el estado vigente de cada uno.<br><br>**Escenario 2:** Dado que el estado de un reporte cambia, cuando el usuario vuelve a consultarlo, entonces el sistema presenta el estado actualizado. | EP04 |
| **EP05** | Inteligencia y confianza de la plataforma | Como equipo de desarrollo, deseamos procesar rutas e incidentes de forma consistente para ofrecer información útil y responsable. | No aplica a nivel de Epic. | — |
| **TS01** | Consultar información geoespacial | Como desarrollador, deseo disponer de un servicio que obtenga rutas e incidentes aplicables para construir las alternativas de recorrido. | **Escenario 1:** Dado un origen y un destino válidos, cuando el servicio recibe la solicitud, entonces devuelve las alternativas disponibles con sus datos geoespaciales.<br><br>**Escenario 2:** Dado que una fuente no responde, cuando se procesa la solicitud, entonces el servicio devuelve un estado controlado y registra la incidencia técnica. | EP05 |
| **TS02** | Estimar el riesgo de una ruta | Como desarrollador, deseo disponer de un servicio de estimación de riesgo para comparar rutas bajo un criterio consistente. | **Escenario 1:** Dada una ruta y la información disponible de incidentes, cuando se solicita una estimación, entonces el servicio devuelve un nivel de riesgo y la vigencia de los datos utilizados.<br><br>**Escenario 2:** Dado que la información es insuficiente, cuando se solicita una estimación, entonces el servicio devuelve un resultado identificado como incierto. | EP05 |
| **TS03** | Procesar la confiabilidad de reportes | Como desarrollador, deseo validar los reportes comunitarios para reducir información duplicada, inconsistente o desactualizada. | **Escenario 1:** Dado que ingresa un reporte, cuando coincide con otro incidente próximo en tipo, espacio y tiempo, entonces el servicio lo identifica como posible duplicado.<br><br>**Escenario 2:** Dado que un reporte supera su periodo de vigencia, cuando se actualiza la información, entonces deja de influir como incidente activo. | EP05 |
| **TS04** | Proteger datos de ubicación | Como desarrollador, deseo limitar el tratamiento de la ubicación a lo necesario para que VSafe gestione la información de manera responsable. | **Escenario 1:** Dado que una función necesita la ubicación, cuando solicita acceso, entonces utiliza únicamente los datos autorizados para esa finalidad.<br><br>**Escenario 2:** Dado que el usuario no autoriza la ubicación, cuando utiliza una función compatible, entonces puede continuar mediante el ingreso manual de datos. | EP05 |

## 3.3 Impact Mapping

El Impact Mapping conecta los resultados de negocio de VSafe con los comportamientos esperados de sus usuarios y con las capacidades que debe entregar el producto. Las metas se formulan para una etapa piloto del MVP y deberán revisarse con evidencia real una vez que se establezcan la fecha de lanzamiento y una línea base de uso.

| Goal | Actor | Impacto esperado | Deliverable | User Stories relacionadas |
|---|---|---|---|---|
| **G01. Alcanzar 300 usuarios activos mensuales al finalizar los primeros tres meses del piloto del MVP.** | Estudiantes y trabajadores que realizan desplazamientos frecuentes. | Incorporan VSafe a la planificación de recorridos cotidianos. | Landing Page con propuesta de valor clara y acceso a la aplicación. | US01, US02, US03 |
| G01 | Estudiantes y trabajadores que realizan desplazamientos frecuentes. | Consultan VSafe antes de iniciar un recorrido. | Búsqueda mediante origen, destino y ubicación actual. | US04, US05 |
| **G02. Lograr que al menos el 60 % de las consultas válidas del piloto termine en la selección de una ruta durante sus primeras ocho semanas.** | Personas que transitan por zonas desconocidas o en horario nocturno. | Comparan explícitamente rapidez y riesgo antes de elegir. | Alternativas de ruta con duración, distancia y riesgo estimado. | US06, US07, TS01, TS02 |
| G02 | Personas que transitan por zonas desconocidas o en horario nocturno. | Revisan el contexto del riesgo antes de comenzar. | Consulta de incidentes relevantes asociados al recorrido. | US08, US09 |
| **G03. Conseguir 100 reportes comunitarios procesables durante los primeros tres meses del piloto.** | Usuarios dispuestos a contribuir con la comunidad. | Registran incidentes con información suficiente y una ubicación confirmada. | Flujo de reporte con categoría, descripción y ubicación aproximada. | US13, US14, US15 |
| G03 | Usuarios que ya enviaron reportes. | Consultan el resultado de su contribución y vuelven a reportar cuando corresponde. | Seguimiento del estado de reportes. | US16, TS03 |
| **G04. Alcanzar una tasa de retorno mensual del 30 % al cierre del tercer mes del piloto.** | Usuarios con recorridos frecuentes. | Mantienen VSafe disponible durante el desplazamiento y reaccionan a información nueva. | Alertas relevantes y recálculo de alternativas. | US10, US11 |
| G04 | Usuarios con recorridos frecuentes. | Reutilizan información de recorridos anteriores. | Historial de rutas consultadas. | US12 |
| G04 | Todos los usuarios de VSafe. | Mantienen confianza en el tratamiento de su información de ubicación. | Controles de autorización y uso limitado de datos de ubicación. | TS04 |

La cadena de impacto prioriza primero la comprensión de la propuesta de valor y la planificación de rutas, ya que ambas capacidades permiten validar el beneficio central de VSafe. Después se incorporan las alertas y la participación comunitaria, que aumentan el valor recurrente de la plataforma y mejoran progresivamente la información disponible.

## 3.4 Product Backlog

El Product Backlog ordena las historias de acuerdo con el valor necesario para validar VSafe. La prioridad inicial permite comunicar la propuesta desde el Landing Page y completar el flujo central de planificación antes de ampliar el acompañamiento en ruta y la colaboración comunitaria. La estimación utiliza Story Points de la serie Fibonacci y representa complejidad relativa, incertidumbre y esfuerzo.

| Orden | User Story ID | Título | Descripción resumida | Story Points |
|---:|---|---|---|---:|
| 1 | US01 | Comprender la propuesta de valor | Explicar el problema, el enfoque y los beneficios de VSafe. | 3 |
| 2 | US02 | Conocer las capacidades principales | Presentar rutas, incidentes, alertas y colaboración comunitaria. | 3 |
| 3 | US03 | Acceder a la aplicación | Conectar el Landing Page con la experiencia principal. | 2 |
| 4 | US04 | Definir origen y destino | Registrar los puntos necesarios para calcular un recorrido. | 5 |
| 5 | US05 | Utilizar la ubicación actual | Permitir el uso autorizado de la posición como origen. | 3 |
| 6 | TS01 | Consultar información geoespacial | Obtener alternativas de ruta e incidentes aplicables. | 8 |
| 7 | US06 | Visualizar rutas alternativas | Presentar diferentes recorridos cuando estén disponibles. | 5 |
| 8 | TS02 | Estimar el riesgo de una ruta | Calcular un nivel de riesgo e informar la vigencia o incertidumbre. | 13 |
| 9 | US07 | Comparar tiempo distancia y riesgo | Facilitar una comparación consistente entre rutas. | 5 |
| 10 | US09 | Consultar incidentes del recorrido | Explicar el contexto asociado al riesgo estimado. | 5 |
| 11 | US08 | Seleccionar una ruta | Establecer una alternativa como recorrido activo. | 3 |
| 12 | US10 | Recibir alertas de incidentes | Informar cambios relevantes durante el trayecto. | 8 |
| 13 | US11 | Solicitar una ruta alternativa | Recalcular el recorrido después de una alerta. | 8 |
| 14 | US13 | Registrar un incidente | Recibir aportes de información de la comunidad. | 5 |
| 15 | US14 | Clasificar el incidente | Asociar el reporte con un tipo comprensible. | 3 |
| 16 | US15 | Confirmar la ubicación del reporte | Evitar que el incidente se asocie a una zona incorrecta. | 3 |
| 17 | TS03 | Procesar la confiabilidad de reportes | Identificar duplicados y controlar la vigencia de los incidentes. | 8 |
| 18 | US16 | Conocer el estado del reporte | Comunicar si el aporte fue procesado por la plataforma. | 5 |
| 19 | US12 | Consultar recorridos anteriores | Permitir la reutilización de información de rutas consultadas. | 3 |
| 20 | TS04 | Proteger datos de ubicación | Limitar el uso de la ubicación a finalidades autorizadas. | 5 |

La suma inicial del Product Backlog es de **103 Story Points**. Este valor no representa una duración comprometida; sirve como referencia para planificar iteraciones una vez que el equipo determine su velocidad. Las historias US01, US02 y US03 deben abordarse desde el primer sprint porque establecen la presencia pública del producto y el acceso al flujo que valida la propuesta central.
