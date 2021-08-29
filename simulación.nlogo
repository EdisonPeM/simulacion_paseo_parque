globals [
  rango-vision-general
  probabilidad-cambio-estado-dueños
  probabilidad-cambio-estado-perros

  total-dueños
  total-callejeros
  total-vecinos
  total-animales

  total-conflicto-agresivo
  total-conflicto-calmado

  total-ataques-vecinos
  total-ataques-animales

  total-agresivos
  total-calmados
]
;; Atributos de los sectores del parque
breed [arboles arbol]

;; Accesorios del parque
breed [flores flor]
breed [canecas caneca]
flores-own [
  nivel-daño ;; estado del objeto
  nivel-maximo-daño
]
canecas-own [
  nivel-daño ;; estado del objeto
  nivel-maximo-daño
]

;; Cosas que aparecen en el piso
breed [comidas comida]
breed [basuras basura]

;; Cosas de mascotas
breed [pelotas pelota]
pelotas-own[
  objetivox ;; variable para ubicar la pelota
  objetivoy ;; variable para ubicar la pelota
  en-movimiento? ;; Variable de estado
  atrapada? ;; variable para saber si la mascota atrapo la pelota
]

breed [popos popo]
popos-own [
  perro-creador ;; variable para relacionar el perro que hizo popo
]
;; --------------- AGENTES ---------------
;; Agentes de perros y sus variables
breed [perros perro]
perros-own [
  velocidad-lenta
  velocidad-normal
  velocidad-rapida

  nivel-daño ;; variable para determinar el nivel de daño
  nivel-maximo-daño
  es-agresivo? ;; Determina que tan calmado es el perro: agresivo(true), calmado(false)
  tiene-dueño? ;; atributo para diferenciar perros con dueño y perros callejeros

  caminando? ;; Estado para cuando el perro camina solo
  saliendo? ;; estado para cuando el perro está escapando

  mi-dueño ;; atributo para relacionar al perro y su dueño
  caminando-con-dueño? ;; estado para cuando el perro camina con su dueño
  jugando-con-dueño? ;; estado para cuando el perro juega con su dueño
  pelota-a-buscar ;; atributo para relacionar al perro y su pelota

  jugando-con-otro? ;; estado para cuando el perro juega con otro animal
  esta-peleando? ;; estado para cuando el perro pelea con otro animal
  otro ;; variable para realcionar el otro animal
]

;; Agentes de las personas y sus variables
breed [dueños dueño]
dueños-own[
  velocidad-lenta
  velocidad-normal
  velocidad-rapida

  mi-mascota ;; variable relacionada a la mascota
  pelota-a-lanzar ;; variable relacionada al pelota
  jugando-con-mascota? ;; variable de estado para cuando está jugando con la mascota
  caminando-con-mascota? ;; estado para cuando camina junto a la mascota
  caminando? ;; estado para cuando camina sola
  saliendo? ;; estado para cuando la persona se quiere ir

  bola-lanzada? ;; estado para lanzar la pelota
]
directed-link-breed [correas correa] ;; relacion entre dueño y mascota

breed [vecinos vecino]
vecinos-own [
  velocidad-lenta
  velocidad-normal
  velocidad-rapida

  nivel-daño ;; nivel de daño recivido por los perros
  nivel-maximo-daño
  caminando? ;; estado para cuando caminan solos
  jugando-con-mascota? ;; estado para cuando están jugando con alguna mascota
  escapando-de-mascota? ;; estado para cuando están escapando de alguna mascota
  mascota  ;; estado para relacionar la mascota con la que interactúa
]

;; Agentes de otros animales
breed [animales animal]
animales-own [
  velocidad-lenta
  velocidad-normal
  velocidad-rapida

  nivel-daño
  nivel-maximo-daño
  caminando? ;; estado para cuando caminan solos
  jugando-con-mascota? ;; variable de estado para cuando están jugando con alguna mascota
  escapando-de-mascota?
  mascota
]

breed [trabajadores trabajador] ;; [ "person police" "person service" ]

;; -------------------- FUNCIONES PRINCIPALES --------------------
to setup ;;para configurar el parque
  clear-all ;;limpiar todo
  set rango-vision-general 5
  set probabilidad-cambio-estado-dueños 200
  set probabilidad-cambio-estado-perros 500

  crear-entorno
  crear-agentes
  reset-ticks ;;redefinir pasos (de tiempo)
end

to go ;; para ejecutar los comportamientos
  if count turtles with [breed = perros or breed = dueños] = 0 [ stop ]

  mover-dueños
  mover-perros
  mover-pelotas

  mover-vecinos
  mover-animales

  tick ;;avanzar un paso de tiempo
end

;; -------------------- FUNCIONES DE INICIO  --------------------
to crear-entorno
  crear-parque
  crear-arboles
  crear-canecas
  crear-flores
  crear-comida
  crear-basura
end

to crear-agentes
  crear-animales
  crear-vecinos
  crear-perros-callejeros
  crear-dueños-y-mascotas
end

to crear-parque
  ask patches [
    set pcolor scale-color one-of [ lime green ] (aleatorio-entre 6 8) 0 10
    if((pxcor = min-pxcor) or (pxcor = max-pxcor) or
      (pycor = min-pycor) or (pycor = max-pycor))
    [set pcolor brown]

    if ((pxcor = min-pxcor) and (abs pycor < 6))
    [set pcolor black]
  ]
end

to crear-arboles
  create-arboles (get-cant-creaciones num-arboles) [
    set size 4
    set color green - 1
    set shape one-of ["tree" "tree pine"]
    setxy get-valid-random-x get-valid-random-y
  ]
end

to crear-flores
  repeat (get-cant-creaciones num-jardines) [
    let rand-x aleatorio-entre (min-pxcor + 4) (max-pxcor - 4)
    let rand-y aleatorio-entre (min-pycor + 4) (max-pycor - 4)
    create-flores 1 [
      set shape one-of ["flower" "flower budding" "plant" "plant medium" "plant small"]
      setxy rand-x (rand-y - 2)
    ]
    create-flores 3 [
      set shape one-of ["flower" "flower budding" "plant" "plant medium" "plant small"]
      setxy ((rand-x - 1) + (who mod 3)) (rand-y - 1)
    ]
    create-flores 5 [
      set shape one-of ["flower" "flower budding" "plant" "plant medium" "plant small"]
      setxy ((rand-x - 2) + (who mod 5)) rand-y
    ]
    create-flores 3 [
      set shape one-of ["flower" "flower budding" "plant" "plant medium" "plant small"]
      setxy ((rand-x - 1) + (who mod 3)) (rand-y + 1)
    ]
    create-flores 1 [
      set shape one-of ["flower" "flower budding" "plant" "plant medium" "plant small"]
      setxy rand-x (rand-y + 2)
    ]
  ]

  ask flores [ set nivel-maximo-daño 7 ]
end

to crear-canecas
  create-canecas (get-cant-creaciones num-canecas) [
    set nivel-maximo-daño 10

    set size 2
    set color gray
    set shape "garbage can"
    setxy get-valid-random-x get-valid-random-y
  ]
end

to crear-basura
  create-basuras (get-cant-creaciones num-basura) [
    set shape one-of [ "bottle" "leaf" "book" "pushpin" "dart" "leaf 2" "letter opened" "letter sealed"]
    setxy get-valid-random-x get-valid-random-y
  ]
end

to crear-comida
  create-comidas (get-cant-creaciones num-comida) [
    set shape one-of ["acorn" "apple" "banana" "pumpkin" "strawberry"]
    setxy get-valid-random-x get-valid-random-y
  ]
end

to crear-animales
  set total-animales (get-cant-creaciones num-animales)
  create-animales total-animales [
    set caminando? true
    set jugando-con-mascota? false
    set escapando-de-mascota? false
    set mascota nobody

    set nivel-maximo-daño 30

    set shape one-of [ "bird" "bug" "butterfly" "caterpillar" "frog top" "mouse top" "squirrel" ]

    set velocidad-lenta 0.1
    set velocidad-normal 0.3
    set velocidad-rapida 0.5

    if((shape = "bird") or (shape = "frog top"))
    [
      set size 1.5
      set velocidad-lenta 0.3
      set velocidad-normal 0.5
      set velocidad-rapida 0.7
    ]

    if(shape = "squirrel")[
      set color scale-color one-of [ gray brown ] (aleatorio-entre 5 10) 0 20
      set velocidad-lenta 0.5
      set velocidad-normal 0.7
      set velocidad-rapida 0.9
      set size 1.5
    ]

    setxy get-valid-random-x get-valid-random-y
  ]
end

to crear-vecinos
  set total-vecinos (get-cant-creaciones num-vecinos)
  create-vecinos total-vecinos [
    set caminando? true
    set jugando-con-mascota? false
    set escapando-de-mascota? false
    set mascota nobody

    set nivel-maximo-daño 40

    set velocidad-lenta 0.8
    set velocidad-normal 1
    set velocidad-rapida 1.2

    set size 3
    setxy get-valid-random-x get-valid-random-y
    set color scale-color one-of [ orange brown pink ] (aleatorio-entre 5 10) 0 20
    set shape one-of [ "person business" "person construction" "person farmer" "person lumberjack" "person student" ]
  ]
end

to crear-perros-callejeros
  set total-callejeros (get-cant-creaciones num-perros-callejeros)
  create-perros total-callejeros [
    set tiene-dueño? false
    set caminando-con-dueño? false
    set jugando-con-dueño? false

    set velocidad-lenta 0.7
    set velocidad-normal 1
    set velocidad-rapida 1.3

    set caminando? true
    set jugando-con-otro? false
    set esta-peleando? false
    set saliendo? false

    set otro nobody

    set nivel-maximo-daño 40

    let agresivo? (random 100 < 50)
    ifelse agresivo? [
      Set es-agresivo? true
      set label "Agresivo"
      set label-color red
      set total-agresivos (total-agresivos + 1)
    ][
      set es-agresivo? false
      set label "Calmado"
      set total-calmados (total-calmados + 1)
    ]

    set size 3
    set shape "perro"
    setxy get-valid-random-x get-valid-random-y
    set color scale-color one-of [ gray red orange brown ] (aleatorio-entre 0 6 ) 0 20
  ]
end

to crear-dueños-y-mascotas
  set total-dueños (get-cant-creaciones num-dueños)
  repeat total-dueños [
    create-dueños 1 [
      set caminando? false
      set saliendo? false
      set caminando-con-mascota? true
      set jugando-con-mascota? false
      set bola-lanzada? false

      set velocidad-lenta 0.8
      set velocidad-normal 1
      set velocidad-rapida 1.5

      set size 3

      setxy get-valid-random-x get-valid-random-y
      set shape "person"
      set color scale-color one-of [ orange brown pink ] (aleatorio-entre 5 10) 0 20

      ;; CREAR LA MASCOTA
      hatch-perros 1 [
        set tiene-dueño? true
        set otro nobody

        set caminando? false
        set caminando-con-dueño? true
        set jugando-con-dueño? false
        set jugando-con-otro? false
        set esta-peleando? false
        set saliendo? false

        set velocidad-lenta 0.7
        set velocidad-normal 1
        set velocidad-rapida 1.3

        set nivel-maximo-daño 40

        set color scale-color one-of [ gray red orange brown ] (aleatorio-entre 8 13) 0 20
        set shape "perro"
        set size 3

        set mi-dueño myself
        create-correa-from mi-dueño [set shape "correa" ]

        facexy get-valid-random-x get-valid-random-y fd 3
        face mi-dueño

        let agresivo? (random 100 < 50)
        ifelse agresivo? [
          Set es-agresivo? true
          set label "Agresivo"
          set label-color red
          set total-agresivos (total-agresivos + 1)
        ][
          set es-agresivo? false
          set label "Calmado"
          ask my-correas [
            set hidden? true
          ]
          set total-calmados (total-calmados + 1)
        ]

        ask myself [
          set mi-mascota myself
        ]
      ]

      ;; CREAR PELOTA
      hatch-pelotas 1 [
        set size 1
        set shape one-of [ "ball baseball" "ball tennis" ]
        set color scale-color one-of [ yellow cyan sky blue magenta ] (aleatorio-entre 6 8) 0 10

        ask myself [set pelota-a-lanzar myself]
        ask [mi-mascota] of myself [set pelota-a-buscar myself]

        set hidden? true
        set en-movimiento? false
        set atrapada? false
      ]
    ]
  ]
end

;; -------------------- FUNCIONES DE COMPORTAMIENTOS --------------------
;; COMPORTAMIENTOS DE LOS DUEÑOS
to mover-dueños
  ask dueños [
    ifelse mi-mascota = nobody [salir]
    [
      ifelse [saliendo?] of mi-mascota [
        if not esta-cerca? mi-mascota rango-vision-general [ seguir-a mi-mascota velocidad-rapida ]
      ][
        cambiar-estado-dueño

        if jugando-con-mascota? [ jugar-con-mascota ]
        if caminando-con-mascota? [ caminar velocidad-lenta 15 ]
        if caminando? [ caminar velocidad-lenta 10 ]
        if saliendo? [ salir ask mi-mascota [ set saliendo? true ]  ]

        if [esta-peleando?] of mi-mascota [
          if random 100 < 15[
            seguir-a mi-mascota velocidad-rapida
            if esta-cerca? mi-mascota rango-vision-general [
              ask mi-mascota [ olvidar-otros ]
            ]
          ]
        ]
      ]

      limpiar-popo
    ]
  ]
end

to limpiar-popo
  if any? popos with [perro-creador = [mi-mascota] of myself] [ ;; aqui myself hace referencia al dueño
    ask one-of popos with [perro-creador = [mi-mascota] of myself] [ ;; aqui myself hace referencia al dueño
      ifelse esta-cerca? myself 1 [ die ] ;; aqui myself hace referencia al dueño
      [
        ask myself [ ;; aqui myself hace referencia al dueño
          if random 100 < 35 [
            seguir-a myself velocidad-normal ;; aqui myself hace referencia a la popo
          ]
        ]
      ]
    ]
  ]
end

to jugar-con-mascota
  let myx xcor
  let myy ycor
  ifelse not bola-lanzada? [
    ;; lanzar bola
    ask pelota-a-lanzar [
      setxy myx myy

      ;; machete para limitar el espacio de lanzamiento de la bola
      set size 2
      set objetivox get-valid-random-x
      set objetivoy get-valid-random-y
      set size 1

      set atrapada? false
      set en-movimiento? true
      set hidden? false
    ]

    set bola-lanzada? true
  ][
    if [atrapada?] of pelota-a-lanzar and esta-cerca? mi-mascota 1.5
    [
      set bola-lanzada? false
      ask pelota-a-lanzar [
        setxy myx myy

        set atrapada? false
        set en-movimiento? false
        set hidden? true
      ]
    ]
  ]
end

to cambiar-estado-dueño
  let estado random probabilidad-cambio-estado-dueños ;; probabilidad de cambiar de estado 1 / prob
  ifelse mi-mascota = nobody [
    set jugando-con-mascota? false
    set caminando-con-mascota? false
    set caminando? false
    set saliendo? true
  ][
    if estado = 1 and not [es-agresivo?] of mi-mascota [
      set jugando-con-mascota? true
      set caminando-con-mascota? false
      set caminando? false
      set saliendo? false

      ask mi-mascota [
        set jugando-con-dueño? true
        set caminando-con-dueño? false
        set caminando? false
        set jugando-con-otro? false
        set esta-peleando? false
        set saliendo? false
      ]
    ]

    if estado = 2 and not [es-agresivo?] of mi-mascota [
      set jugando-con-mascota? false
      set caminando-con-mascota? true
      set caminando? false
      set saliendo? false

      ask mi-mascota [
        set jugando-con-dueño? false
        set caminando-con-dueño? true
        set caminando? false
        set jugando-con-otro? false
        set esta-peleando? false
        set saliendo? false
      ]
    ]

    if estado = 3 and not [es-agresivo?] of mi-mascota [
      set jugando-con-mascota? false
      set caminando-con-mascota? false
      set caminando? true
      set saliendo? false

      ask mi-mascota [
        set jugando-con-dueño? false
        set caminando-con-dueño? false
        set caminando? true
        set jugando-con-otro? false
        set esta-peleando? false
        set saliendo? false
      ]
    ]

    if estado = 4 and not [es-agresivo?] of mi-mascota [
      set jugando-con-mascota? false
      set caminando-con-mascota? false
      set caminando? false
      set saliendo? false

      ask mi-mascota [
        set jugando-con-dueño? false
        set caminando-con-dueño? false
        set caminando? true
        set jugando-con-otro? false
        set esta-peleando? false
        set saliendo? false
      ]
    ]
  ]
end

to mover-pelotas
  ask pelotas[
    if en-movimiento? [
      ifelse esta-cerca-xy? objetivox objetivoy 1
      [ set en-movimiento? false ]
      [ facexy objetivox objetivoy fd 1.5 ]
    ]
  ]
end

;; COMPORTAMIENTOS DE LAS MASCOTAS
to mover-perros
  ask perros [
    ifelse (nivel-daño > nivel-maximo-daño) or (tiene-dueño? and mi-dueño = nobody) [
      set saliendo? true
      salir
    ][
      ifelse saliendo?  [
        ifelse tiene-dueño? and esta-cerca? mi-dueño rango-vision-general [
          if esta-cerca? mi-dueño 1 [ set saliendo? false ]
          seguir-a mi-dueño velocidad-rapida
        ]
        [ salir ]
      ][
        ifelse jugando-con-dueño?
        [ jugar-con-dueño ]
        [
          ifelse caminando-con-dueño?
          [ caminar-con-dueño ]
          [
            cambiar-estado-mascota

            ifelse otro = nobody [
              if caminando? [ caminar velocidad-lenta 30 ]

              if random 100 < 30 [ notar-otro-perro (size + 1) ]
              if random 100 < 30 [ notar-otro-agente animales (size + 1) ]
              if random 100 < 30 [ notar-otro-agente vecinos (size + 1) ]
            ][
              if jugando-con-otro?
              [ jugar-con otro velocidad-normal ]

              if esta-peleando?
              [ pelear-con otro ]

              if random 100 < 5 [ olvidar-otros ]
            ]
          ]
        ]

        hacer-popo
        comer-cosas
        dañar-cosas
      ]
    ]
  ]
end

to hacer-popo
  if random 1000 = 1 [
    hatch-popos 1
    [
      set shape "poop"
      set size 1
      set label ""
      set heading 0
      set perro-creador myself
    ]
  ]
end

to comer-cosas
  if random 100 < 30 [
    ask comidas in-radius 0.5 [ die ]
    ask basuras in-radius 0.5 [
      die

      ask myself [
        if esta-cerca? mi-dueño rango-vision-general
        [
          ask mi-dueño[
            set jugando-con-mascota? true
            set caminando-con-mascota? false
            set caminando? false
            set saliendo? true
          ]

          set jugando-con-dueño? false
          set caminando-con-dueño? false
          set caminando? false
          set jugando-con-otro? false
          set esta-peleando? false
          set saliendo? true
        ]
      ]
    ]
  ]
end

to dañar-cosas
  if es-agresivo? and random 100 < 30 [
    ask canecas in-radius 2 [
      ifelse (nivel-daño = nivel-maximo-daño - 1) [ set color 0 set label "" ]
      [
        set nivel-daño (nivel-daño + 1)
        set color scale-color gray nivel-daño nivel-maximo-daño (- nivel-maximo-daño)
        set label nivel-daño
        set label-color red
        if(
          any? dueños in-radius rango-vision-general or
          any? vecinos in-radius rango-vision-general
        )
        [
          ask myself [
            if tiene-dueño? and mi-dueño != nobody [
              ask mi-dueño[
                set jugando-con-mascota? true
                set caminando-con-mascota? false
                set caminando? false
                set saliendo? true
              ]
            ]
            set jugando-con-dueño? false
            set caminando-con-dueño? false
            set caminando? false
            set jugando-con-otro? false
            set esta-peleando? false
            set saliendo? true
          ]
        ]
      ]
    ]
  ]

  if es-agresivo? and random 100 < 30 [
    ask flores in-radius 2 [
      ifelse (nivel-daño = nivel-maximo-daño - 1) [ set color 0 set label "" ]
      [
        set nivel-daño (nivel-daño + 1)
        set color scale-color color nivel-daño nivel-maximo-daño (- nivel-maximo-daño)
        set label nivel-daño
        set label-color red
        if(
          any? dueños in-radius rango-vision-general or
          any? vecinos in-radius rango-vision-general
        )
        [
          ask myself [
            if tiene-dueño? and mi-dueño != nobody [
              ask mi-dueño[
                set jugando-con-mascota? true
                set caminando-con-mascota? false
                set caminando? false
                set saliendo? true
              ]
            ]
            set jugando-con-dueño? false
            set caminando-con-dueño? false
            set caminando? false
            set jugando-con-otro? false
            set esta-peleando? false
            set saliendo? true
          ]
        ]
      ]
    ]
  ]
end

to cambiar-estado-mascota
  let estado random probabilidad-cambio-estado-perros
  if estado = 3 [
    olvidar-otros
    set caminando? true
    set saliendo? false
  ]

  if estado = 2 [
    olvidar-otros
    set caminando? false
    set saliendo? true
  ]

  if estado = 1 [
    olvidar-otros
    set caminando? false
    set saliendo? false
  ]
end

to jugar-con-dueño
  if [bola-lanzada?] of mi-dueño [
    if esta-cerca? pelota-a-buscar 1 [
      ask pelota-a-buscar [
        set atrapada? true
        set hidden? true
      ]
    ]

    if not esta-cerca? mi-dueño 1.2 or not [atrapada?] of pelota-a-buscar [
      ifelse [atrapada?] of pelota-a-buscar [
        seguir-a mi-dueño velocidad-normal
      ][
        seguir-a pelota-a-buscar velocidad-normal
      ]
    ]
  ]
end

to caminar-con-dueño
  ifelse esta-cerca? mi-dueño 2
  [ set heading [heading] of mi-dueño ]
  [ face mi-dueño ]
  caminar velocidad-lenta 0
end

to notar-otro-perro [radio]
  ask (other perros) in-radius radio [
    ask myself [
      set otro myself
      ifelse es-agresivo? and [es-agresivo?] of otro [
        set total-conflicto-agresivo (total-conflicto-agresivo + 1)
        set esta-peleando? true
        set jugando-con-otro? false
        set jugando-con-dueño? false
        set caminando-con-dueño? false
        set caminando? false
        set saliendo? false
      ][
        ifelse not es-agresivo? and not [es-agresivo?] of otro [
          set esta-peleando? false
          set jugando-con-otro? true
          set jugando-con-dueño? false
          set caminando-con-dueño? false
          set caminando? false
          set saliendo? false
        ][
          ifelse random 100 < 50
          [
            set esta-peleando? false
            set jugando-con-otro? true
            set jugando-con-dueño? false
            set caminando-con-dueño? false
            set caminando? false
            set saliendo? false
          ]
          [
            set total-conflicto-calmado (total-conflicto-calmado + 1)
            set esta-peleando? true
            set jugando-con-otro? false
            set jugando-con-dueño? false
            set caminando-con-dueño? false
            set caminando? false
            set saliendo? false
          ]
        ]
      ]
    ]
  ]
end

to notar-otro-agente [breed-set radio]
  ask breed-set in-radius radio [
    ask myself [
      set otro myself
      ifelse es-agresivo? [
        set esta-peleando? true
        set jugando-con-otro? false
        set jugando-con-dueño? false
        set caminando-con-dueño? false
        set caminando? false
        set saliendo? false
      ][
        set esta-peleando? false
        set jugando-con-otro? true
        set jugando-con-dueño? false
        set caminando-con-dueño? false
        set caminando? false
        set saliendo? false
      ]
    ]

    ifelse [es-agresivo?] of myself
    [
      set caminando? false
      set jugando-con-mascota? false
      set escapando-de-mascota? true
      if (breed-set = vecinos) [ set total-ataques-vecinos (total-ataques-vecinos + 1) ]
      if (breed-set = animales) [ set total-ataques-animales (total-ataques-animales + 1) ]
      set mascota myself
    ][
      set caminando? false
      set jugando-con-mascota? true
      set escapando-de-mascota? false
      set mascota myself
    ]
  ]
end

to olvidar-otros
  set otro nobody
  set caminando? true
  set saliendo? false
  set jugando-con-otro? false
  set esta-peleando? false

  ask perros with [otro = myself] [
    set otro nobody
    set caminando? true
    set saliendo? false
    set jugando-con-otro? false
    set esta-peleando? false
  ]

  ask animales with [mascota = myself] [
    olvidar-mascota
  ]

  ask vecinos with [mascota = myself] [
    olvidar-mascota
  ]
end

;; COMPORTAMIENTOS DE VECINOS Y ANIMALES ---------------
to mover-vecinos
  ask vecinos [
    if mascota = nobody [ olvidar-mascota ]

    if nivel-daño >= nivel-maximo-daño [
      if mascota != nobody [ ask mascota [ olvidar-otros ] ]
      salir
    ]

    if caminando? [ caminar velocidad-lenta 20 ]
    if jugando-con-mascota? [ jugar-con mascota velocidad-normal ]
    if escapando-de-mascota? [ huir-de mascota velocidad-rapida ]
  ]
end

to mover-animales
  ask animales[
    if mascota = nobody [ olvidar-mascota ]

    if nivel-daño >= nivel-maximo-daño [
      if mascota != nobody [ ask mascota [ olvidar-otros ] ]
      die
    ]

    if shape = "bird" or shape = "frog top" or shape = "squirrel" [
      if caminando? [ caminar velocidad-lenta 40 ]
      if jugando-con-mascota? [ jugar-con mascota velocidad-normal ]
      if escapando-de-mascota? [ huir-de mascota velocidad-rapida ]
    ]

    if shape = "bug" or shape = "butterfly" or shape = "caterpillar" or shape =  "mouse top" [
      if caminando? [ caminar velocidad-lenta 40 ]
      if jugando-con-mascota? [ jugar-con mascota velocidad-normal ]
      if escapando-de-mascota? [ huir-de mascota velocidad-rapida ]
    ]
  ]
end

to olvidar-mascota
  set caminando? true
  set jugando-con-mascota? false
  set escapando-de-mascota? false
  set mascota nobody
end

;; --------------- COMPORTAMIENTOS GENERALES ---------------
to caminar [avance probabilidad-giro]
  ifelse(
    (ycor > (max-pycor - ((1 + size) / 2 )) - avance) or
    (ycor < (min-pycor + ((1 + size) / 2 )) + avance) or
    (xcor > (max-pxcor - ((1 + size) / 2 )) - avance) or
    (
      (xcor < (min-pxcor + ((1 + size) / 2 )) + avance) and
      (abs ycor > 4)
    )
  )
  [
    facexy get-valid-random-x get-valid-random-y
  ]
  [
    if (pcolor = black) [ die ]
    if (random 100 < probabilidad-giro) [
      rt random aleatorio-entre -100 100
    ]
  ]

  fd avance
end

to salir
  facexy 0 0 caminar 1 0
end

to seguir-a [agente avance]
  face agente
  caminar avance 0
end

to jugar-con [agente avance]
  face agente
  ifelse esta-cerca? agente size
  [ rt 89 caminar (avance / 2) 0 ]
  [ caminar avance 0 ]
end

to pelear-con [ agente ]
  face agente
  ifelse esta-cerca? agente (size - 1) [
    rt random 180 caminar 1 0
    ask otro [ set nivel-daño (nivel-daño + 1) ]
  ][
    caminar 1 0
  ]
end

to huir-de [agente avance]
  face agente rt 180
  caminar avance 0
end

;; --------------- FUNCIONES AUXILIARES ---------------
to-report aleatorio-entre [lim-inf lim-sup]
  report random (lim-sup - lim-inf + 1) + lim-inf
end

to-report get-cant-creaciones [numTotal]
  if (tipo-de-creacion = "fija") [ report numTotal ]
  report random numTotal
end

to-report get-valid-random-x
  report aleatorio-entre (min-pxcor + 1 + size / 2) (max-pxcor - 1 - size / 2)
end

to-report get-valid-random-y
  report aleatorio-entre (min-pycor + 1 + size / 2) (max-pycor - 1 - size / 2)
end

to-report esta-cerca? [turtle-agent dist]
  report (distance turtle-agent) < dist
end

to-report esta-cerca-xy? [posx posy dist]
  report (distancexy posx posy) < dist
end
@#$#@#$#@
GRAPHICS-WINDOW
505
27
1005
528
-1
-1
12.0
1
10
1
1
1
0
0
0
1
0
40
-20
20
1
1
1
ticks
30.0

BUTTON
321
36
395
69
reiniciar
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
404
37
467
70
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
123
141
295
174
num-jardines
num-jardines
0
20
0.0
1
1
NIL
HORIZONTAL

SLIDER
123
191
295
224
num-canecas
num-canecas
0
5
0.0
1
1
NIL
HORIZONTAL

SLIDER
123
241
295
274
num-basura
num-basura
0
15
0.0
1
1
NIL
HORIZONTAL

SLIDER
123
290
295
323
num-comida
num-comida
0
15
0.0
1
1
NIL
HORIZONTAL

SLIDER
123
92
295
125
num-arboles
num-arboles
0
10
0.0
1
1
NIL
HORIZONTAL

SLIDER
312
153
484
186
num-perros-callejeros
num-perros-callejeros
0
10
0.0
1
1
NIL
HORIZONTAL

SLIDER
312
253
484
286
num-animales
num-animales
0
30
0.0
1
1
NIL
HORIZONTAL

SLIDER
312
203
484
236
num-vecinos
num-vecinos
0
15
0.0
1
1
NIL
HORIZONTAL

SLIDER
312
104
484
137
num-dueños
num-dueños
0
15
1.0
1
1
NIL
HORIZONTAL

CHOOSER
140
28
278
73
tipo-de-creacion
tipo-de-creacion
"fija" "aleatoria"
0

MONITOR
194
350
394
395
Total dueños retirados del parque
total-dueños - (count dueños)
3
1
11

MONITOR
196
415
391
460
Total perros retirados del parque
total-callejeros - count perros with [tiene-dueño? = false]
2
1
11

MONITOR
193
484
394
529
Total vecinos retirados del parque
total-vecinos - count vecinos
3
1
11

MONITOR
1024
163
1249
208
Total conflictos entre perros agresivos
total-conflicto-agresivo
17
1
11

MONITOR
1024
222
1308
267
Total conflicto entre perros calmados y agresivos
total-conflicto-calmado
17
1
11

MONITOR
1024
282
1186
327
Total de ataques a vecinos
total-ataques-vecinos
17
1
11

MONITOR
1024
342
1191
387
Total de ataques a animales
total-ataques-animales
17
1
11

MONITOR
1024
423
1166
468
Total canecas dañadas
count canecas with [nivel-daño > 0]
17
1
11

MONITOR
1024
483
1150
528
Total flores dañadas
count flores with [nivel-daño > 0]
17
1
11

MONITOR
1025
29
1234
74
Total perros agresivos en el parque
total-agresivos
17
1
11

MONITOR
1025
83
1235
128
Total perros calmados en el parque 
total-calmados
17
1
11

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

acorn
false
0
Polygon -7500403 true true 146 297 120 285 105 270 75 225 60 180 60 150 75 105 225 105 240 150 240 180 225 225 195 270 180 285 155 297
Polygon -6459832 true false 121 15 136 58 94 53 68 65 46 90 46 105 75 115 234 117 256 105 256 90 239 68 209 57 157 59 136 8
Circle -16777216 false false 223 95 18
Circle -16777216 false false 219 77 18
Circle -16777216 false false 205 88 18
Line -16777216 false 214 68 223 71
Line -16777216 false 223 72 225 78
Line -16777216 false 212 88 207 82
Line -16777216 false 206 82 195 82
Line -16777216 false 197 114 201 107
Line -16777216 false 201 106 193 97
Line -16777216 false 198 66 189 60
Line -16777216 false 176 87 180 80
Line -16777216 false 157 105 161 98
Line -16777216 false 158 65 150 56
Line -16777216 false 180 79 172 70
Line -16777216 false 193 73 197 66
Line -16777216 false 237 82 252 84
Line -16777216 false 249 86 253 97
Line -16777216 false 240 104 252 96

apple
false
0
Polygon -7500403 true true 33 58 0 150 30 240 105 285 135 285 150 270 165 285 195 285 255 255 300 150 268 62 226 43 194 36 148 32 105 35
Line -16777216 false 106 55 151 62
Line -16777216 false 157 62 209 57
Polygon -6459832 true false 152 62 158 62 160 46 156 30 147 18 132 26 142 35 148 46
Polygon -16777216 false false 132 25 144 38 147 48 151 62 158 63 159 47 155 30 147 18

ball baseball
false
0
Circle -7500403 true true 30 30 240
Polygon -2674135 true false 247 79 243 86 237 106 232 138 232 167 235 199 239 215 244 225 236 234 229 221 224 196 220 163 221 138 227 102 234 83 240 71
Polygon -2674135 true false 53 79 57 86 63 106 68 138 68 167 65 199 61 215 56 225 64 234 71 221 76 196 80 163 79 138 73 102 66 83 60 71
Line -2674135 false 241 149 210 149
Line -2674135 false 59 149 90 149
Line -2674135 false 241 171 212 176
Line -2674135 false 246 191 218 203
Line -2674135 false 251 207 227 226
Line -2674135 false 251 93 227 74
Line -2674135 false 246 109 218 97
Line -2674135 false 241 129 212 124
Line -2674135 false 59 171 88 176
Line -2674135 false 59 129 88 124
Line -2674135 false 54 109 82 97
Line -2674135 false 49 93 73 74
Line -2674135 false 54 191 82 203
Line -2674135 false 49 207 73 226

ball tennis
false
0
Circle -7500403 true true 30 30 240
Circle -7500403 false true 30 30 240
Polygon -16777216 true false 50 82 54 90 59 107 64 140 64 164 63 189 59 207 54 222 68 236 76 220 81 195 84 163 83 139 78 102 72 83 63 67
Polygon -16777216 true false 250 82 246 90 241 107 236 140 236 164 237 189 241 207 246 222 232 236 224 220 219 195 216 163 217 139 222 102 228 83 237 67
Polygon -1 true false 247 79 243 86 237 106 232 138 232 167 235 199 239 215 244 225 236 234 229 221 224 196 220 163 221 138 227 102 234 83 240 71
Polygon -1 true false 53 79 57 86 63 106 68 138 68 167 65 199 61 215 56 225 64 234 71 221 76 196 80 163 79 138 73 102 66 83 60 71

banana
false
0
Polygon -7500403 false true 25 78 29 86 30 95 27 103 17 122 12 151 18 181 39 211 61 234 96 247 155 259 203 257 243 245 275 229 288 205 284 192 260 188 249 187 214 187 188 188 181 189 144 189 122 183 107 175 89 158 69 126 56 95 50 83 38 68
Polygon -7500403 true true 39 69 26 77 30 88 29 103 17 124 12 152 18 179 34 205 60 233 99 249 155 260 196 259 237 248 272 230 289 205 284 194 264 190 244 188 221 188 185 191 170 191 145 190 123 186 108 178 87 157 68 126 59 103 52 88
Line -16777216 false 54 169 81 195
Line -16777216 false 75 193 82 199
Line -16777216 false 99 211 118 217
Line -16777216 false 241 211 254 210
Line -16777216 false 261 224 276 214
Polygon -16777216 true false 283 196 273 204 287 208
Polygon -16777216 true false 36 114 34 129 40 136
Polygon -16777216 true false 46 146 53 161 53 152
Line -16777216 false 65 132 82 162
Line -16777216 false 156 250 199 250
Polygon -16777216 true false 26 77 30 90 50 85 39 69

bird
true
0
Polygon -7500403 true true 135 165 90 270 120 300 180 300 210 270 165 165
Rectangle -7500403 true true 120 105 180 237
Polygon -7500403 true true 135 105 120 75 105 45 121 6 167 8 207 25 257 46 180 75 165 105
Circle -16777216 true false 128 21 42
Polygon -7500403 true true 163 116 194 92 212 86 230 86 250 90 265 98 279 111 290 126 296 143 298 158 298 166 296 183 286 204 272 219 259 227 235 240 241 223 250 207 251 192 245 180 232 168 216 162 200 162 186 166 175 173 171 180
Polygon -7500403 true true 137 116 106 92 88 86 70 86 50 90 35 98 21 111 10 126 4 143 2 158 2 166 4 183 14 204 28 219 41 227 65 240 59 223 50 207 49 192 55 180 68 168 84 162 100 162 114 166 125 173 129 180

bird side
true
0
Polygon -7500403 true true 0 120 45 90 75 90 105 120 150 120 240 135 285 120 285 135 300 150 240 150 195 165 255 195 210 195 150 210 90 195 60 180 45 135
Circle -16777216 true false 38 98 14

book
false
0
Polygon -7500403 true true 30 195 150 255 270 135 150 75
Polygon -7500403 true true 30 135 150 195 270 75 150 15
Polygon -7500403 true true 30 135 30 195 90 150
Polygon -1 true false 39 139 39 184 151 239 156 199
Polygon -1 true false 151 239 254 135 254 90 151 197
Line -7500403 true 150 196 150 247
Line -7500403 true 43 159 138 207
Line -7500403 true 43 174 138 222
Line -7500403 true 153 206 248 113
Line -7500403 true 153 221 248 128
Polygon -1 true false 159 52 144 67 204 97 219 82

bottle
false
0
Circle -7500403 true true 90 240 60
Rectangle -1 true false 135 8 165 31
Line -7500403 true 123 30 175 30
Circle -7500403 true true 150 240 60
Rectangle -7500403 true true 90 105 210 270
Rectangle -7500403 true true 120 270 180 300
Circle -7500403 true true 90 45 120
Rectangle -7500403 true true 135 27 165 51

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

caterpillar
true
0
Polygon -7500403 true true 165 210 165 225 135 255 105 270 90 270 75 255 75 240 90 210 120 195 135 165 165 135 165 105 150 75 150 60 135 60 120 45 120 30 135 15 150 15 180 30 180 45 195 45 210 60 225 105 225 135 210 150 210 165 195 195 180 210
Line -16777216 false 135 255 90 210
Line -16777216 false 165 225 120 195
Line -16777216 false 135 165 180 210
Line -16777216 false 150 150 201 186
Line -16777216 false 165 135 210 150
Line -16777216 false 165 120 225 120
Line -16777216 false 165 106 221 90
Line -16777216 false 157 91 210 60
Line -16777216 false 150 60 180 45
Line -16777216 false 120 30 96 26
Line -16777216 false 124 0 135 15

container
false
0
Rectangle -7500403 false false 0 75 300 225
Rectangle -7500403 true true 0 75 300 225
Line -16777216 false 0 210 300 210
Line -16777216 false 0 90 300 90
Line -16777216 false 150 90 150 210
Line -16777216 false 120 90 120 210
Line -16777216 false 90 90 90 210
Line -16777216 false 240 90 240 210
Line -16777216 false 270 90 270 210
Line -16777216 false 30 90 30 210
Line -16777216 false 60 90 60 210
Line -16777216 false 210 90 210 210
Line -16777216 false 180 90 180 210

crate
false
0
Rectangle -7500403 true true 45 45 255 255
Rectangle -16777216 false false 45 45 255 255
Rectangle -16777216 false false 60 60 240 240
Line -16777216 false 180 60 180 240
Line -16777216 false 150 60 150 240
Line -16777216 false 120 60 120 240
Line -16777216 false 210 60 210 240
Line -16777216 false 90 60 90 240
Polygon -7500403 true true 75 240 240 75 240 60 225 60 60 225 60 240
Polygon -16777216 false false 60 225 60 240 75 240 240 75 240 60 225 60

dart
true
0
Polygon -7500403 true true 135 90 150 285 165 90
Polygon -7500403 true true 135 285 105 255 105 240 120 210 135 180 150 165 165 180 180 210 195 240 195 255 165 285
Rectangle -1184463 true false 135 45 165 90
Line -16777216 false 150 285 150 180
Polygon -16777216 true false 150 45 135 45 146 35 150 0 155 35 165 45
Line -16777216 false 135 75 165 75
Line -16777216 false 135 60 165 60

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

flower budding
false
0
Polygon -7500403 true true 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Polygon -7500403 true true 189 233 219 188 249 173 279 188 234 218
Polygon -7500403 true true 180 255 150 210 105 210 75 240 135 240
Polygon -7500403 true true 180 150 180 120 165 97 135 84 128 121 147 148 165 165
Polygon -7500403 true true 170 155 131 163 175 167 196 136

frog top
true
0
Polygon -7500403 true true 146 18 135 30 119 42 105 90 90 150 105 195 135 225 165 225 195 195 210 150 195 90 180 41 165 30 155 18
Polygon -7500403 true true 91 176 67 148 70 121 66 119 61 133 59 111 53 111 52 131 47 115 42 120 46 146 55 187 80 237 106 269 116 268 114 214 131 222
Polygon -7500403 true true 185 62 234 84 223 51 226 48 234 61 235 38 240 38 243 60 252 46 255 49 244 95 188 92
Polygon -7500403 true true 115 62 66 84 77 51 74 48 66 61 65 38 60 38 57 60 48 46 45 49 56 95 112 92
Polygon -7500403 true true 200 186 233 148 230 121 234 119 239 133 241 111 247 111 248 131 253 115 258 120 254 146 245 187 220 237 194 269 184 268 186 214 169 222
Circle -16777216 true false 157 38 18
Circle -16777216 true false 125 38 18

garbage can
false
0
Polygon -16777216 false false 60 240 66 257 90 285 134 299 164 299 209 284 234 259 240 240
Rectangle -7500403 true true 60 75 240 240
Polygon -7500403 true true 60 238 66 256 90 283 135 298 165 298 210 283 235 256 240 238
Polygon -7500403 true true 60 75 66 57 90 30 135 15 165 15 210 30 235 57 240 75
Polygon -7500403 true true 60 75 66 93 90 120 135 135 165 135 210 120 235 93 240 75
Polygon -16777216 false false 59 75 66 57 89 30 134 15 164 15 209 30 234 56 239 75 235 91 209 120 164 135 134 135 89 120 64 90
Line -16777216 false 210 120 210 285
Line -16777216 false 90 120 90 285
Line -16777216 false 125 131 125 296
Line -16777216 false 65 93 65 258
Line -16777216 false 175 131 175 296
Line -16777216 false 235 93 235 258
Polygon -16777216 false false 112 52 112 66 127 51 162 64 170 87 185 85 192 71 180 54 155 39 127 36

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

leaf 2
false
0
Rectangle -7500403 true true 144 218 156 298
Polygon -7500403 true true 150 263 133 276 102 276 58 242 35 176 33 139 43 114 54 123 62 87 75 53 94 30 104 39 120 9 155 31 180 68 191 56 216 85 235 125 240 173 250 165 248 205 225 247 200 271 176 275

letter opened
false
0
Rectangle -7500403 true true 30 90 270 225
Rectangle -16777216 false false 30 90 270 225
Line -16777216 false 150 30 270 105
Line -16777216 false 30 105 150 30
Line -16777216 false 270 225 181 161
Line -16777216 false 30 225 119 161
Polygon -6459832 true false 30 105 150 30 270 105 150 180
Line -16777216 false 30 105 270 105
Line -16777216 false 270 105 150 180
Line -16777216 false 30 105 150 180

letter sealed
false
0
Rectangle -7500403 true true 30 90 270 225
Rectangle -16777216 false false 30 90 270 225
Line -16777216 false 270 105 150 180
Line -16777216 false 30 105 150 180
Line -16777216 false 270 225 181 161
Line -16777216 false 30 225 119 161

mouse top
true
0
Polygon -7500403 true true 144 238 153 255 168 260 196 257 214 241 237 234 248 243 237 260 199 278 154 282 133 276 109 270 90 273 83 283 98 279 120 282 156 293 200 287 235 273 256 254 261 238 252 226 232 221 211 228 194 238 183 246 168 246 163 232
Polygon -7500403 true true 120 78 116 62 127 35 139 16 150 4 160 16 173 33 183 60 180 80
Polygon -7500403 true true 119 75 179 75 195 105 190 166 193 215 165 240 135 240 106 213 110 165 105 105
Polygon -7500403 true true 167 69 184 68 193 64 199 65 202 74 194 82 185 79 171 80
Polygon -7500403 true true 133 69 116 68 107 64 101 65 98 74 106 82 115 79 129 80
Polygon -16777216 true false 163 28 171 32 173 40 169 45 166 47
Polygon -16777216 true false 137 28 129 32 127 40 131 45 134 47
Polygon -16777216 true false 150 6 143 14 156 14
Line -7500403 true 161 17 195 10
Line -7500403 true 160 22 187 20
Line -7500403 true 160 22 201 31
Line -7500403 true 140 22 99 31
Line -7500403 true 140 22 113 20
Line -7500403 true 139 17 105 10

pencil
false
0
Polygon -7500403 true true 255 60 255 90 105 240 90 225
Polygon -7500403 true true 60 195 75 210 240 45 210 45
Polygon -7500403 true true 90 195 105 210 255 60 240 45
Polygon -6459832 true false 90 195 60 195 45 255 105 240 105 210
Polygon -16777216 true false 45 255 74 248 75 240 60 225 51 225

perro
true
0
Circle -16777216 true false 145 18 14
Polygon -7500403 true true 122 75 125 61 132 52 141 46 152 45 164 47 172 53 178 61 180 75
Polygon -7500403 true true 138 51 138 38 139 31 143 25 152 22 161 24 164 30 165 38 165 51
Polygon -7500403 true true 155 75 155 245 147 245 138 244 132 242 124 238 118 233 114 228 111 221 110 213 111 205 114 198 117 193 118 190 120 186 121 181 122 177 122 173 122 164 123 168 122 161 122 157 120 152 118 149 115 144 113 138 112 131 112 125 112 119 113 115 114 111 116 107 118 104 120 101 122 97 125 92 126 87 126 83 126 79 125 75 135 75 142 75 149 75
Polygon -7500403 true true 171 70 177 68 183 63 188 60 195 60 199 62 204 67 206 73 209 81 212 91 206 91 198 90 194 89 189 85 184 87 179 89 172 90 165 89 165 84 165 80 165 75 165 70
Polygon -7500403 true true 130 69 124 67 118 62 113 59 106 59 102 61 97 66 95 72 92 80 89 90 95 90 103 89 107 88 112 84 117 86 122 88 129 89 136 88 136 83 136 79 136 74 136 69
Polygon -7500403 true true 144 238 137 248 139 252 136 255 130 266 131 269 127 272 129 289 138 294 142 294 144 291 148 288 152 285 152 280 154 280 154 274 153 269 152 265 154 266 156 261 156 261 156 254 155 250 157 250 157 247 157 247 157 238
Polygon -7500403 true true 145 75 145 245 153 245 162 244 168 242 176 238 182 233 186 228 189 221 190 213 189 205 186 198 183 193 182 190 180 186 179 181 178 177 178 173 178 164 177 168 178 161 178 157 180 152 182 149 185 144 187 138 188 131 188 125 188 119 187 115 186 111 184 107 182 104 180 101 178 97 175 92 174 87 174 83 174 79 175 75 165 75 158 75 151 75
Polygon -16777216 true false 146 59 142 54 138 54 134 58 138 62 142 62
Polygon -16777216 true false 158 59 162 54 166 54 170 58 166 62 162 62

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

person business
false
0
Rectangle -1 true false 120 90 180 180
Polygon -13345367 true false 135 90 150 105 135 180 150 195 165 180 150 105 165 90
Polygon -7500403 true true 120 90 105 90 60 195 90 210 116 154 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 183 153 210 210 240 195 195 90 180 90 150 165
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 76 172 91
Line -16777216 false 172 90 161 94
Line -16777216 false 128 90 139 94
Polygon -13345367 true false 195 225 195 300 270 270 270 195
Rectangle -13791810 true false 180 225 195 300
Polygon -14835848 true false 180 226 195 226 270 196 255 196
Polygon -13345367 true false 209 202 209 216 244 202 243 188
Line -16777216 false 180 90 150 165
Line -16777216 false 120 90 150 165

person construction
false
0
Rectangle -7500403 true true 123 76 176 95
Polygon -1 true false 105 90 60 195 90 210 115 162 184 163 210 210 240 195 195 90
Polygon -13345367 true false 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Circle -7500403 true true 110 5 80
Line -16777216 false 148 143 150 196
Rectangle -16777216 true false 116 186 182 198
Circle -1 true false 152 143 9
Circle -1 true false 152 166 9
Rectangle -16777216 true false 179 164 183 186
Polygon -955883 true false 180 90 195 90 195 165 195 195 150 195 150 120 180 90
Polygon -955883 true false 120 90 105 90 105 165 105 195 150 195 150 120 120 90
Rectangle -16777216 true false 135 114 150 120
Rectangle -16777216 true false 135 144 150 150
Rectangle -16777216 true false 135 174 150 180
Polygon -955883 true false 105 42 111 16 128 2 149 0 178 6 190 18 192 28 220 29 216 34 201 39 167 35
Polygon -6459832 true false 54 253 54 238 219 73 227 78
Polygon -16777216 true false 15 285 15 255 30 225 45 225 75 255 75 270 45 285

person doctor
false
0
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -13345367 true false 135 90 150 105 135 135 150 150 165 135 150 105 165 90
Polygon -7500403 true true 105 90 60 195 90 210 135 105
Polygon -7500403 true true 195 90 240 195 210 210 165 105
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -1 true false 105 90 60 195 90 210 114 156 120 195 90 270 210 270 180 195 186 155 210 210 240 195 195 90 165 90 150 150 135 90
Line -16777216 false 150 148 150 270
Line -16777216 false 196 90 151 149
Line -16777216 false 104 90 149 149
Circle -1 true false 180 0 30
Line -16777216 false 180 15 120 15
Line -16777216 false 150 195 165 195
Line -16777216 false 150 240 165 240
Line -16777216 false 150 150 165 150

person farmer
false
0
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -1 true false 60 195 90 210 114 154 120 195 180 195 187 157 210 210 240 195 195 90 165 90 150 105 150 150 135 90 105 90
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -13345367 true false 120 90 120 180 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 180 90 172 89 165 135 135 135 127 90
Polygon -6459832 true false 116 4 113 21 71 33 71 40 109 48 117 34 144 27 180 26 188 36 224 23 222 14 178 16 167 0
Line -16777216 false 225 90 270 90
Line -16777216 false 225 15 225 90
Line -16777216 false 270 15 270 90
Line -16777216 false 247 15 247 90
Rectangle -6459832 true false 240 90 255 300

person graduate
false
0
Circle -16777216 false false 39 183 20
Polygon -1 true false 50 203 85 213 118 227 119 207 89 204 52 185
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -8630108 true false 90 19 150 37 210 19 195 4 105 4
Polygon -8630108 true false 120 90 105 90 60 195 90 210 120 165 90 285 105 300 195 300 210 285 180 165 210 210 240 195 195 90
Polygon -1184463 true false 135 90 120 90 150 135 180 90 165 90 150 105
Line -2674135 false 195 90 150 135
Line -2674135 false 105 90 150 135
Polygon -1 true false 135 90 150 105 165 90
Circle -1 true false 104 205 20
Circle -1 true false 41 184 20
Circle -16777216 false false 106 206 18
Line -2674135 false 208 22 208 57

person lumberjack
false
0
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -2674135 true false 60 196 90 211 114 155 120 196 180 196 187 158 210 211 240 196 195 91 165 91 150 106 150 135 135 91 105 91
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -6459832 true false 174 90 181 90 180 195 165 195
Polygon -13345367 true false 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -6459832 true false 126 90 119 90 120 195 135 195
Rectangle -6459832 true false 45 180 255 195
Polygon -16777216 true false 255 165 255 195 240 225 255 240 285 240 300 225 285 195 285 165
Line -16777216 false 135 165 165 165
Line -16777216 false 135 135 165 135
Line -16777216 false 90 135 120 135
Line -16777216 false 105 120 120 120
Line -16777216 false 180 120 195 120
Line -16777216 false 180 135 210 135
Line -16777216 false 90 150 105 165
Line -16777216 false 225 165 210 180
Line -16777216 false 75 165 90 180
Line -16777216 false 210 150 195 165
Line -16777216 false 180 105 210 180
Line -16777216 false 120 105 90 180
Line -16777216 false 150 135 150 165
Polygon -2674135 true false 100 30 104 44 189 24 185 10 173 10 166 1 138 -1 111 3 109 28

person police
false
0
Polygon -1 true false 124 91 150 165 178 91
Polygon -13345367 true false 134 91 149 106 134 181 149 196 164 181 149 106 164 91
Polygon -13345367 true false 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -13345367 true false 120 90 105 90 60 195 90 210 116 158 120 195 180 195 184 158 210 210 240 195 195 90 180 90 165 105 150 165 135 105 120 90
Rectangle -7500403 true true 123 76 176 92
Circle -7500403 true true 110 5 80
Polygon -13345367 true false 150 26 110 41 97 29 137 -1 158 6 185 0 201 6 196 23 204 34 180 33
Line -13345367 false 121 90 194 90
Line -16777216 false 148 143 150 196
Rectangle -16777216 true false 116 186 182 198
Rectangle -16777216 true false 109 183 124 227
Rectangle -16777216 true false 176 183 195 205
Circle -1 true false 152 143 9
Circle -1 true false 152 166 9
Polygon -1184463 true false 172 112 191 112 185 133 179 133
Polygon -1184463 true false 175 6 194 6 189 21 180 21
Line -1184463 false 149 24 197 24
Rectangle -16777216 true false 101 177 122 187
Rectangle -16777216 true false 179 164 183 186

person service
false
0
Polygon -7500403 true true 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -1 true false 120 90 105 90 60 195 90 210 120 150 120 195 180 195 180 150 210 210 240 195 195 90 180 90 165 105 150 165 135 105 120 90
Polygon -1 true false 123 90 149 141 177 90
Rectangle -7500403 true true 123 76 176 92
Circle -7500403 true true 110 5 80
Line -13345367 false 121 90 194 90
Line -16777216 false 148 143 150 196
Rectangle -16777216 true false 116 186 182 198
Circle -1 true false 152 143 9
Circle -1 true false 152 166 9
Rectangle -16777216 true false 179 164 183 186
Polygon -2674135 true false 180 90 195 90 183 160 180 195 150 195 150 135 180 90
Polygon -2674135 true false 120 90 105 90 114 161 120 195 150 195 150 135 120 90
Polygon -2674135 true false 155 91 128 77 128 101
Rectangle -16777216 true false 118 129 141 140
Polygon -2674135 true false 145 91 172 77 172 101

person soldier
false
0
Rectangle -7500403 true true 127 79 172 94
Polygon -10899396 true false 105 90 60 195 90 210 135 105
Polygon -10899396 true false 195 90 240 195 210 210 165 105
Circle -7500403 true true 110 5 80
Polygon -10899396 true false 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -6459832 true false 120 90 105 90 180 195 180 165
Line -6459832 false 109 105 139 105
Line -6459832 false 122 125 151 117
Line -6459832 false 137 143 159 134
Line -6459832 false 158 179 181 158
Line -6459832 false 146 160 169 146
Rectangle -6459832 true false 120 193 180 201
Polygon -6459832 true false 122 4 107 16 102 39 105 53 148 34 192 27 189 17 172 2 145 0
Polygon -16777216 true false 183 90 240 15 247 22 193 90
Rectangle -6459832 true false 114 187 128 208
Rectangle -6459832 true false 177 187 191 208

person student
false
0
Polygon -13791810 true false 135 90 150 105 135 165 150 180 165 165 150 105 165 90
Polygon -7500403 true true 195 90 240 195 210 210 165 105
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -1 true false 100 210 130 225 145 165 85 135 63 189
Polygon -13791810 true false 90 210 120 225 135 165 67 130 53 189
Polygon -1 true false 120 224 131 225 124 210
Line -16777216 false 139 168 126 225
Line -16777216 false 140 167 76 136
Polygon -7500403 true true 105 90 60 195 90 210 135 105

petals
false
0
Circle -7500403 true true 117 12 66
Circle -7500403 true true 116 221 67
Circle -7500403 true true 41 41 67
Circle -7500403 true true 11 116 67
Circle -7500403 true true 41 191 67
Circle -7500403 true true 191 191 67
Circle -7500403 true true 221 116 67
Circle -7500403 true true 191 41 67
Circle -7500403 true true 60 60 180

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

plant medium
false
0
Rectangle -7500403 true true 135 165 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 165 120 120 150 90 180 120 165 165

plant small
false
0
Rectangle -7500403 true true 135 240 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 240 120 195 150 165 180 195 165 240

poop
true
0
Circle -6459832 true false 89 108 78
Circle -6459832 true false 129 100 76
Circle -6459832 true false 150 140 84
Polygon -6459832 true false 92 248 108 257 124 260 143 263 182 261 209 258 235 257 171 124 128 124
Rectangle -1 true false 159 162 201 181
Circle -6459832 true false 192 191 67
Circle -6459832 true false 61 151 78
Circle -6459832 true false 41 191 67
Circle -6459832 true false 120 75 60
Polygon -6459832 true false 123 58 131 63 137 74 128 86 173 86 166 69 162 64 156 59 150 56 141 55 141 55
Circle -1 true false 99 159 42
Circle -1 true false 99 144 42
Rectangle -1 true false 99 165 141 181
Circle -1 true false 159 144 42
Circle -1 true false 159 159 42
Circle -16777216 true false 105 150 30
Circle -16777216 true false 105 165 30
Circle -16777216 true false 165 165 30
Circle -16777216 true false 165 150 30
Rectangle -16777216 true false 105 165 135 180
Rectangle -16777216 true false 165 165 195 180
Polygon -1 true false 101 212 182 212 196 213 199 217 200 221 197 227 174 234 143 238 143 238 120 234 102 227 96 223 95 219 94 216 97 213

pumpkin
false
0
Polygon -7500403 false true 148 30 107 33 74 44 33 58 15 105 0 150 30 240 105 285 135 285 150 270 165 285 195 285 255 255 300 150 268 62 225 43 196 36
Polygon -7500403 true true 33 58 0 150 30 240 105 285 135 285 150 270 165 285 195 285 255 255 300 150 268 62 226 43 194 36 148 32 105 35
Polygon -16777216 false false 108 40 75 57 42 101 32 177 79 253 124 285 133 285 147 268 122 222 103 176 107 131 122 86 140 52 154 42 193 66 204 101 216 158 212 209 188 256 164 278 163 283 196 285 234 255 257 199 268 137 251 84 229 52 191 41 163 38 151 41
Polygon -6459832 true false 133 50 171 50 167 32 155 15 146 2 117 10 126 23 130 33
Polygon -16777216 false false 117 10 127 26 129 35 132 49 170 49 168 32 154 14 145 1

pushpin
false
0
Polygon -7500403 true true 130 158 105 180 93 205 119 196 142 173
Polygon -16777216 true false 121 112 111 128 109 143 112 158 123 175 138 184 156 189 169 188 186 177 199 158 139 98
Circle -7500403 true true 126 86 90
Polygon -16777216 true false 159 103 152 114 151 125 152 135 158 144 169 150 182 151 194 149 207 142 238 111 191 72
Polygon -16777216 true false 187 56 177 72 175 87 178 102 189 119 204 128 222 133 235 132 252 121 265 102 205 42
Circle -7500403 true true 190 30 90

sheep
true
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

squirrel
false
0
Polygon -7500403 true true 87 267 106 290 145 292 157 288 175 292 209 292 207 281 190 276 174 277 156 271 154 261 157 245 151 230 156 221 171 209 214 165 231 171 239 171 263 154 281 137 294 136 297 126 295 119 279 117 241 145 242 128 262 132 282 124 288 108 269 88 247 73 226 72 213 76 208 88 190 112 151 107 119 117 84 139 61 175 57 210 65 231 79 253 65 243 46 187 49 157 82 109 115 93 146 83 202 49 231 13 181 12 142 6 95 30 50 39 12 96 0 162 23 250 68 275
Polygon -16777216 true false 237 85 249 84 255 92 246 95
Line -16777216 false 221 82 213 93
Line -16777216 false 253 119 266 124
Line -16777216 false 278 110 278 116
Line -16777216 false 149 229 135 211
Line -16777216 false 134 211 115 207
Line -16777216 false 117 207 106 211
Line -16777216 false 91 268 131 290
Line -16777216 false 220 82 213 79
Line -16777216 false 286 126 294 128
Line -16777216 false 193 284 206 285

strawberry
false
0
Polygon -7500403 false true 149 47 103 36 72 45 58 62 37 88 35 114 34 141 84 243 122 290 151 280 162 288 194 287 239 227 284 122 267 64 224 45 194 38
Polygon -7500403 true true 72 47 38 88 34 139 85 245 122 289 150 281 164 288 194 288 239 228 284 123 267 65 225 46 193 39 149 48 104 38
Polygon -10899396 true false 136 62 91 62 136 77 136 92 151 122 166 107 166 77 196 92 241 92 226 77 196 62 226 62 241 47 166 57 136 32
Polygon -16777216 false false 135 62 90 62 135 75 135 90 150 120 166 107 165 75 196 92 240 92 225 75 195 61 226 62 239 47 165 56 135 30
Line -16777216 false 105 120 90 135
Line -16777216 false 75 120 90 135
Line -16777216 false 75 150 60 165
Line -16777216 false 45 150 60 165
Line -16777216 false 90 180 105 195
Line -16777216 false 120 180 105 195
Line -16777216 false 120 225 105 240
Line -16777216 false 90 225 105 240
Line -16777216 false 120 255 135 270
Line -16777216 false 120 135 135 150
Line -16777216 false 135 210 150 225
Line -16777216 false 165 180 180 195

tile brick
false
0
Rectangle -1 true false 0 0 300 300
Rectangle -7500403 true true 15 225 150 285
Rectangle -7500403 true true 165 225 300 285
Rectangle -7500403 true true 75 150 210 210
Rectangle -7500403 true true 0 150 60 210
Rectangle -7500403 true true 225 150 300 210
Rectangle -7500403 true true 165 75 300 135
Rectangle -7500403 true true 15 75 150 135
Rectangle -7500403 true true 0 0 60 60
Rectangle -7500403 true true 225 0 300 60
Rectangle -7500403 true true 75 0 210 60

tile log
false
0
Rectangle -7500403 true true 0 0 300 300
Line -16777216 false 0 30 45 15
Line -16777216 false 45 15 120 30
Line -16777216 false 120 30 180 45
Line -16777216 false 180 45 225 45
Line -16777216 false 225 45 165 60
Line -16777216 false 165 60 120 75
Line -16777216 false 120 75 30 60
Line -16777216 false 30 60 0 60
Line -16777216 false 300 30 270 45
Line -16777216 false 270 45 255 60
Line -16777216 false 255 60 300 60
Polygon -16777216 false false 15 120 90 90 136 95 210 75 270 90 300 120 270 150 195 165 150 150 60 150 30 135
Polygon -16777216 false false 63 134 166 135 230 142 270 120 210 105 116 120 88 122
Polygon -16777216 false false 22 45 84 53 144 49 50 31
Line -16777216 false 0 180 15 180
Line -16777216 false 15 180 105 195
Line -16777216 false 105 195 180 195
Line -16777216 false 225 210 165 225
Line -16777216 false 165 225 60 225
Line -16777216 false 60 225 0 210
Line -16777216 false 300 180 264 191
Line -16777216 false 255 225 300 210
Line -16777216 false 16 196 116 211
Line -16777216 false 180 300 105 285
Line -16777216 false 135 255 240 240
Line -16777216 false 240 240 300 255
Line -16777216 false 135 255 105 285
Line -16777216 false 180 0 240 15
Line -16777216 false 240 15 300 0
Line -16777216 false 0 300 45 285
Line -16777216 false 45 285 45 270
Line -16777216 false 45 270 0 255
Polygon -16777216 false false 150 270 225 300 300 285 228 264
Line -16777216 false 223 209 255 225
Line -16777216 false 179 196 227 183
Line -16777216 false 228 183 266 192

tile stones
false
0
Polygon -7500403 true true 0 240 45 195 75 180 90 165 90 135 45 120 0 135
Polygon -7500403 true true 300 240 285 210 270 180 270 150 300 135 300 225
Polygon -7500403 true true 225 300 240 270 270 255 285 255 300 285 300 300
Polygon -7500403 true true 0 285 30 300 0 300
Polygon -7500403 true true 225 0 210 15 210 30 255 60 285 45 300 30 300 0
Polygon -7500403 true true 0 30 30 0 0 0
Polygon -7500403 true true 15 30 75 0 180 0 195 30 225 60 210 90 135 60 45 60
Polygon -7500403 true true 0 105 30 105 75 120 105 105 90 75 45 75 0 60
Polygon -7500403 true true 300 60 240 75 255 105 285 120 300 105
Polygon -7500403 true true 120 75 120 105 105 135 105 165 165 150 240 150 255 135 240 105 210 105 180 90 150 75
Polygon -7500403 true true 75 300 135 285 195 300
Polygon -7500403 true true 30 285 75 285 120 270 150 270 150 210 90 195 60 210 15 255
Polygon -7500403 true true 180 285 240 255 255 225 255 195 240 165 195 165 150 165 135 195 165 210 165 255

tile water
false
0
Rectangle -7500403 true true -1 0 299 300
Polygon -1 true false 105 259 180 290 212 299 168 271 103 255 32 221 1 216 35 234
Polygon -1 true false 300 161 248 127 195 107 245 141 300 167
Polygon -1 true false 0 157 45 181 79 194 45 166 0 151
Polygon -1 true false 179 42 105 12 60 0 120 30 180 45 254 77 299 93 254 63
Polygon -1 true false 99 91 50 71 0 57 51 81 165 135
Polygon -1 true false 194 224 258 254 295 261 211 221 144 199

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

tree pine
false
0
Rectangle -6459832 true false 120 225 180 300
Polygon -7500403 true true 150 240 240 270 150 135 60 270
Polygon -7500403 true true 150 75 75 210 150 195 225 210
Polygon -7500403 true true 150 7 90 157 150 142 210 157 150 7

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113
@#$#@#$#@
NetLogo 6.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

correa
0.5
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
@#$#@#$#@
0
@#$#@#$#@
