<p align="center">
    <img src="https://upload.wikimedia.org/wikipedia/commons/f/fc/UPC_logo_transparente.png"></img><br>
    <strong>Universidad Peruana de Ciencias Aplicadas</strong><br>
    <br>
    <strong>Ingeniería de Software</strong><br><br>
    <strong>1ASI0657  Fundamentos de Arquitectura de Software</strong><br>
    <strong>202610</strong>
    <br><br> 
    <strong>NRC: 7940</strong>
     <br><br> 
    <strong>Profesor: Marino Humberto Jara Palacios</strong>
    <br>
    <strong><br> 
     <strong>TRABAJO FINAL</strong>
     <br> 
         <br> 
     <strong> Nombre del Producto :</strong> VSafe
</p>


<div align="center">

| Alumno | Código |
|:---:|:---:|
| Gianfranco Jared Durand Vega | u202312614 |
| Stephano Mayrzon Landauri Preciado | u202311828 |
| Oscar Leonel Espinoza Quijandría | u |
| Olimpo | U202312614 |

</div>

 Versión | Fecha | Autor(es) | Descripción |
|---------|-------|-----------|-------------|


## Student Outcome

El curso contribuye al cumplimiento del Student Outcome ABET:

**ABET – EAC - Student Outcome 7**

**Aprendizaje Continuo y Autónomo**

**Criterio:** La capacidad de adquirir y aplicar nuevos conocimientos según sea necesario, utilizando estrategias de aprendizaje apropiadas.

En el siguiente cuadro se describen las acciones realizadas y las conclusiones del equipo que sustentan el cumplimiento del **ABET – EAC - Student Outcome 7**.

| Criterio específico | Acciones realizadas | Conclusiones |
|---------------------|--------------------|---------------|


## Contenido

### Tabla de contenidos

- [Student Outcome](#student-outcome)
- [Capítulo I: Introducción](#capítulo-i-introducción)
  - [1.1 Startup Profile](#11-startup-profile)
    - [1.1.1 Descripción de la Startup](#111-descripción-de-la-startup)
    - [1.1.2 Perfiles de integrantes del equipo](#112-perfiles-de-integrantes-del-equipo)
  - [1.2 Solution Profile](#12-solution-profile)
    - [1.2.1 Nombre del producto](#121-nombre-del-producto)
    - [1.2.2 Antecedentes y problemática](#122-antecedentes-y-problemática)
    - [1.2.3 Lean UX Process](#123-lean-ux-process)
      - [1.2.3.1 Lean UX Problem Statement](#1231-lean-ux-problem-statement)
      - [1.2.3.2 Lean UX Assumptions](#1232-lean-ux-assumptions)
      - [1.2.3.3 Lean UX Hypothesis](#1233-lean-ux-hypothesis)
      - [1.2.3.4 Lean UX Canvas](#1234-lean-ux-canvas)
  - [1.3 Segmentos objetivo](#13-segmentos-objetivo)
- [Capítulo II: Requirements & Analysis](#capítulo-ii-requirements--analysis)
  - [2.1 Competidores](#21-competidores)
  - [2.2 Entrevistas](#22-entrevistas)
  - [2.3 Needfinding](#23-needfinding)
    - [2.3.1 User Personas](#231-user-personas)
    - [2.3.2 User Task Matrix](#232-user-task-matrix)
    - [2.3.3 Empathy Maps](#233-empathy-maps)
    - [2.3.4 As-is Scenario Mapping](#234-as-is-scenario-mapping)
- [Capítulo III: Requirements Specification](#capítulo-iii-requirements-specification)
  - [3.1 To-Be Scenario Mapping](#31-to-be-scenario-mapping)
  - [3.2 User Stories](#32-user-stories)
  - [3.3 Impact Map](#33-impact-map)
  - [3.4 Product Backlog](#34-product-backlog)
- [Capítulo IV: Product Architecture Design](#capítulo-iv-product-architecture-design)
  - [4.1 Design Concepts, ViewPoints & ER Diagrams](#41-design-concepts-viewpoints--er-diagrams)
    - [4.1.1 Principles Statements](#411-principles-statements)
    - [4.1.2 Approaches Statements Architectural Styles & Patterns](#412-approaches-statements-architectural-styles--patterns)
    - [4.1.3 Context Diagram](#413-context-diagram)
    - [4.1.4 Approach driven ViewPoints Diagrams](#414-approach-driven-viewpoints-diagrams)
    - [4.1.5 Relational/Non Relational Database Diagram](#415-relationalnon-relational-database-diagram)
    - [4.1.6 Design Patterns](#416-design-patterns)
    - [4.1.7 Tactics](#417-tactics)
  - [4.2 Architectural Drivers](#42-architectural-drivers)
    - [4.1.8 Design Purpose](#418-design-purpose)
    - [4.1.9 Primary Functionality (Primary User Stories)](#419-primary-functionality-primary-user-stories)
    - [4.1.10 Quality Attribute Scenarios](#4110-quality-attribute-scenarios)
    - [4.1.11 Constraints](#4111-constraints)
    - [4.1.12 Architectural Concerns](#4112-architectural-concerns)
  - [4.3 ADD Iterations](#43-add-iterations)
- [Capítulo V: Product Implementation, Validation & Deployment](#capítulo-v-product-implementation-validation--deployment)
  - [5.1 Testing Suites & General Patterns](#51-testing-suites--general-patterns)
    - [5.1.1 Backend Application Core Testing Suite](#511-backend-application-core-testing-suite)
    - [5.1.2 Pattern Based Backend Application(s)](#512-pattern-based-backend-applications)
    - [5.1.3 Pattern Based Custom Software Library](#513-pattern-based-custom-software-library)
    - [5.1.4 Framework Pattern Driven Refactoring Report](#514-framework-pattern-driven-refactoring-report)
  - [5.2 Software Configuration Management](#52-software-configuration-management)
    - [5.2.1 Software Development Environment Configuration](#521-software-development-environment-configuration)
    - [5.2.2 Source Code Management](#522-source-code-management)
    - [5.2.3 Source Code Style Guide & Conventions](#523-source-code-style-guide--conventions)
    - [5.2.4 Software Deployment Configuration](#524-software-deployment-configuration)
  - [5.3 Microservices Implementation](#53-microservices-implementation)
    - [Sprint 1](#sprint-1)
    - [Sprint 2](#sprint-2)
    - [Sprint 3](#sprint-3)
    - [Sprint 4](#sprint-4)
  - [5.4 Microservices Deployment](#54-microservices-deployment)
    - [5.3.1 Cloud Architecture Diagram](#531-cloud-architecture-diagram)
    - [5.3.2 Cloud Architecture Deployment](#532-cloud-architecture-deployment)
- [Conclusiones](#conclusiones)
- [Referencias Bibliográficas](#referencias-bibliográficas)
- [Anexos](#anexos)


## Capítulo I: Introducción

### 1.1 Startup Profile

#### 1.1.1 Descripción de la Startup

Vsafe es una startup tecnológica enfocada en mejorar la experiencia de desplazamiento de las personas dentro de la ciudad mediante una plataforma de navegación urbana inteligente. Nuestra solución utiliza inteligencia artificial, geolocalización y reportes de incidentes para recomendar rutas considerando no solo aspectos como el tiempo y la distancia, sino también el nivel de riesgo estimado de las zonas por las que transita el usuario. A través de la plataforma, los usuarios podrán ingresar un punto de origen y destino para visualizar diferentes alternativas de recorrido, conocer incidentes reportados cerca de su ubicación y recibir alertas sobre situaciones que puedan afectar su desplazamiento. Asimismo, podrán contribuir con la comunidad registrando incidentes relacionados con robos, asaltos u otras situaciones que puedan representar un riesgo para las personas que transitan por determinadas zonas. Nuestra startup busca complementar los sistemas tradicionales de navegación incorporando la seguridad como un criterio adicional para la elección de una ruta. De esta manera, los usuarios podrán contar con mayor información antes y durante sus desplazamientos y elegir el recorrido que mejor se adapte a sus necesidades.

### Misión

Facilitar el desplazamiento urbano de las personas mediante una solución tecnológica que combine inteligencia artificial, geolocalización y reportes de incidentes para recomendar rutas rápidas y con un menor nivel de riesgo estimado.

### Visión

Convertirse en una plataforma de navegación urbana reconocida por incorporar la seguridad como un factor importante dentro de la planificación de rutas, contribuyendo a que las personas puedan movilizarse de manera más informada por la ciudad.

### Valores

Nuestros valores se basan en la innovación, utilizando nuevas tecnologías para mejorar la experiencia de navegación urbana; la seguridad, priorizando información que permita a los usuarios tomar mejores decisiones durante sus recorridos; la colaboración, fomentando la participación de la comunidad mediante el reporte de incidentes; la accesibilidad, desarrollando una plataforma sencilla y fácil de utilizar; y la responsabilidad, gestionando adecuadamente la información y ubicación de los usuarios.

### Objetivo General

Desarrollar una plataforma de navegación urbana inteligente que permita a los usuarios encontrar rutas rápidas y con menor nivel de riesgo estimado mediante el uso de inteligencia artificial, geolocalización y reportes de incidentes.

#### 1.1.2 Perfiles de integrantes del equipo

| Foto                                          | Nombre completo               | Código     | Carrera                | Habilidades técnicas y rol                                   |
|-----------------------------------------------|-------------------------------|------------|------------------------|--------------------------------------------------------------|
| <img width="1200" height="1600" alt="image" src="https://github.com/user-attachments/assets/43c33c6b-80d5-4599-92aa-06d6a8ce4bec" />] | Gianfranco Jared Durand Vega    | U202312614 | Ingeniería de Software | Desarrollo Frontend (Vue/React), UI/UX, Integración de servicios externos |


### 1.2 Solution Profile

#### 1.2.1 Nombre del producto

**Vsafe** es una startup tecnológica enfocada en mejorar la experiencia de desplazamiento de las personas dentro de la ciudad mediante una plataforma de navegación urbana inteligente. La solución utiliza inteligencia artificial, geolocalización y reportes de incidentes para recomendar rutas considerando no solo factores como el tiempo y la distancia, sino también el nivel de riesgo estimado de las zonas por las que transita el usuario. A través de la plataforma, los usuarios podrán ingresar un punto de origen y destino, visualizar diferentes alternativas de recorrido, conocer incidentes reportados cerca de su ubicación y recibir alertas sobre situaciones que puedan afectar su desplazamiento. Asimismo, podrán contribuir con la comunidad registrando incidentes relacionados con robos, asaltos u otras situaciones de riesgo, permitiendo que Vsafe complemente los sistemas tradicionales de navegación al incorporar la seguridad como un criterio adicional para elegir una ruta.

### 1.2.2. Antecedentes y problemática

La inseguridad ciudadana representa una preocupación importante para las personas que se desplazan diariamente dentro de los espacios urbanos. Según el Instituto Nacional de Estadística e Informática (INEI, 2026), durante el año 2025 el **84.4 % de la población urbana de 15 años a más consideraba que podía ser víctima de algún hecho delictivo durante los siguientes doce meses**, mientras que en Lima Metropolitana esta percepción alcanzó el **85.5 %**; además, el **62.9 % de la población de Lima Metropolitana manifestó sentirse insegura al caminar sola durante la noche por su zona o barrio**, evidenciando que la seguridad puede influir en las decisiones relacionadas con los desplazamientos cotidianos. En este contexto, las herramientas de navegación suelen centrarse principalmente en factores como la distancia, el tiempo y el tráfico, a pesar de que diferentes investigaciones han demostrado que es posible incorporar datos relacionados con criminalidad e incidentes para calcular rutas considerando también niveles de riesgo (Galbrun et al., 2016; Mata et al., 2016). Asimismo, Sohrabi et al. (2022) señalan que la búsqueda de rutas con criterios de seguridad requiere considerar diferentes fuentes de información, métodos para estimar riesgos y el equilibrio entre la rapidez y la seguridad del recorrido. Frente a esta problemática, se propone **Vsafe**, una plataforma que utiliza inteligencia artificial, geolocalización y reportes de incidentes para estimar el nivel de riesgo de diferentes recorridos y ofrecer a los usuarios alternativas que les permitan desplazarse de manera más informada.

#### Análisis 5W + 2H

| Elemento | Descripción |
| --- | --- |
| **What? (¿Qué?)** | Dificultad de las personas para conocer y considerar el nivel de riesgo de determinadas zonas al momento de seleccionar una ruta para desplazarse por la ciudad. |
| **Why? (¿Por qué?)** | Porque los sistemas de navegación suelen priorizar factores como el tiempo y la distancia, mientras que la información relacionada con incidentes o niveles de riesgo no siempre se encuentra integrada dentro del proceso de selección de una ruta (Galbrun et al., 2016). |
| **Who? (¿Quién?)** | Personas que se desplazan diariamente por la ciudad, especialmente estudiantes, trabajadores, peatones y usuarios que deben transitar por zonas que desconocen. |
| **Where? (¿Dónde?)** | En entornos urbanos, principalmente en ciudades que presentan altos niveles de percepción de inseguridad, como Lima Metropolitana (INEI, 2026). |
| **When? (¿Cuándo?)** | Durante los desplazamientos cotidianos, especialmente cuando una persona se moviliza por lugares desconocidos, durante la noche o cuando debe elegir entre diferentes recorridos para llegar a un destino. |
| **How? (¿Cómo?)** | Los usuarios seleccionan sus recorridos principalmente a partir de información relacionada con distancia, tiempo o tráfico, sin disponer necesariamente de información integrada sobre incidentes ocurridos en las zonas por las que transitarán. |
| **How much? (¿Cuánto?)** | En 2025, el 84.4 % de la población urbana del Perú consideraba que podía ser víctima de un hecho delictivo durante los siguientes doce meses, mientras que en Lima Metropolitana esta cifra alcanzó el 85.5 % (INEI, 2026). |

---




---

## Registro de Versiones del Informe
