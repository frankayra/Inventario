## Archivos de Mapas y Delimitaciones:
    - Como obligatoriamente para iniciar la app tenemos que tener un mapa cargado, si el mismo no se encuentra en la carpeta destinada para la app por el almacenamiento, se le dara la opcion al usuario de cargar el mapa seleccionando un archivo .mbtiles. Si no lo carga, Copio el mapa habana.mbtiles a los archivos y ahi lo dejo. 
    - Lo mismo NO ocurre con las delimitaciones, ya que estas no son necesarias para iniciar la app. Sin embargo, se dara un boton para tener la opcion de seleccionar una o multiples delimitaciones, estas se agregaran al mapa y se copiaran en la carpeta correspondiente destinada para la app por el almacenamiento del telefono.
    - Solo puede haber una sola delimitacion inicial, y esta debe ser de poligonos obligatoriamente, no puede contener mas nada que no sean poligonos, ya que esta se usara para detectar 










# Remake

### Detalles generales
  - El mapa esta dividido en manzanas, cada manzana en parcelas y cada parcela en edificios.
  - Las parcelas tienen un numero unico asociado.
  - CADA EDIFICIO debera clasificarse de acuerdo con 5 variables: Edificación, Terreno, Construcción, Uso de suelos y patentes comerciales, Medidores Electricos.
      
  - Hacer un registro de una variable sobre un edificio es lo mismo que rellenar cada sub-campo de esa variable con los datos del edificio que se perciben.
  - 5 Variables, y CADA variable tiene sus propios sub-campos
  - **Edificacion**. Distrito, Edificio, Cantidad de pisos, Cantidad de sótanos, Antejardín, Material de la fachada, Canoas bajantes.
      **Aclaraciones**: 
      - El numero de edificio, refiere al lugar que ocupa el mismo en un orden especifico dentro de su parcela. El orden es de arriba hacia abajo, de izquierda a derecha.
      - Si NO HAY EDIFICIOS en la parcela, como igualmente se debe realizar un registro de la variable sobre la parcela, se rellena el campo "Edificio" con `0`, "Antejardín" con `998`, "Materia de la fachada" con `998`, "Canoas bajantes" con `998` y se rellenan los otros sub-campos sobre la informacion de la parcela en general.
      - Si NO HAY EDIFICIOS, pero hay uno o más en construcción, en el campo "Edificio" se rellenará con el valor `996`, "Antejardín" con `996` también, y se rellenará la información restante sobre la parcela en general. (**Preguntas[1]**).
  - **Terreno**. Nivel predio 1, Nivel predio 2, Nivel predio 3, Acera, Observaciones, Ancho de acera (**Pregunta[2]**)
      **Aclaraciones**:  [*Vacio hasta ahora*]
  - **Construcción**. Estado del inmueble, Observaciones, Foto
  - **Uso de suelo y patentes comerciales**. Nivel Piso, Número local, Actividad primaria, Actividad complementaria, Estado del Negocio, Nombre negocio, Cantidad de parqueos, Documentos mostrados, Nombre del patentado(texto[auto]), Número de patente comercial(num[1-13 dígitos]), Número de cédula(num[bastantes digitos también]), Nombre de la actividad registrada en la patente(texto), Tiene autorizadas más patentes(bool), Número de patente 2(num[1-13 digitos][se activa a consecuencia]), Tiene permiso de salud(bool), Número de permiso de salud(texto[se activa a consecuencia]), Fecha de vigencia permiso de salud(texto[se aciva a consecuencia]), Código CIIU permiso de salud(texto[se activa a consecuencia]), Se trata de un local de un mercado(bool), "Número de local(mercado)"(num[num de dígitos indef.][se activa a consecuencia]), Tiene patente de licores(bool), Número de patente de licores(num[num de dígitos indef.][se activa a consecuencia]), Área de la actividad(selección simple), Teléfono patentado(num[8 dig]), Correo electrónico(texto), Cantidad de empleados antes COVID(num), Cantidad de empleados actual(num), Afectaciones por COVID personal y desempeño de la empresa(selección múltiple), Afectaciones por COVID sobre las ventas(selección múltiple), Código CIIU-CAECR actividad primaria encontrada(texto[no disponible]), Código CIIU-CAECR actividad complementaria encontrada(texto[no disponible]), Observaciones(texto), Captura de Foto(foto)
      - 
      **Aclaraciones**:
      - Debe existir una barra de búsqueda que nos permita por ahora escribir y presentarla como barra de búsqueda, que tenga como nombre de campo: "Buscar cuenta en Maestro de Licencias Comerciales" que al parecer es una base de datos que nos será proporcionada más adelante
      - Esta barra en el futuro deberá servir para autorellenar varios campos(no todos) del registro actual de la variable "Uso de suelos y..."(La actual) (**Pregunta[3]**)
      - Acá debería existir una manera de abstraer la barra de búsqueda ya mencionada, para de alguna forma introducir desde main.dart, donde se debe buscar la misma para el autorellenado.
      - El sub-campo "Estado del negocio", es un campo de selección MÚLTIPLE, que dará a escoger de la lista siguiente:
        1. En Operación
        2. Cierre temporal
        3. Desocupado con Rótulo SE ALQUILA
        4. Cierre total
        5. Ha modificado la actividad autorizada(EXPRESS u otra actividad)
      - El sub-campo "Documentos mostrados" es un campo de selección SIMPLE que dará a escoger entre las siguientes opciones:
        1. Certificado Patente
        2. Recibo al día(menos dos meses de atraso)
        3. Recibo atrasado (con más de dos meses de atraso)
        4. Certificado de trámite "CT", Indicar el número
        5. No muestra documentos de patente
      - Al marcar la casilla del sub-campo "Tiene autorizadas más patentes" se podrá disponible el sub-campo "Número de patente 2"
      - Al marcar la casilla del sub-campo "Tiene permiso de salud" se podrán disponibles los sub-campos "Numero de permiso de salud", "Fecha vigencia permiso de salud", "Código CIIU permiso de salud"
      - Al marcar la casilla del sub-campo "Se trata de un local de un mercado" se podrá disponible el sub-campo "Número de local(mercado)"
      - Al marcar la casilla del sub-campo "Tiene patente de licores" se podrá disponible el sub-campo "Número de patente de licores"
      - El sub-campo "Área de la actividad" es un campo de selección SIMPLE que dará a escoger entre las siguientes opciones:
        1. Menos de 50m²
        2. 51 a 100m²
        3. 100 a 200m²
        4. 200 a 400m²
        5. 400 a 1000m²
        6. Más de 1000m²
        7. 998. No aplica
        8. 999. No visible
      - El sub-campo "Afectaciones por COVID personal y desempeño de la empresa", es un campo de selección MÚLTIPLE, que dará a escoger de la lista siguiente:
        1. Despido de empleados
        2. Reducción jornada laboral
        3. Suspensión del contrato laboral
        4. Se adelantaron vacaciones
        5. Se empezó a trabajar por turnos
        6. Se aumentaron las jornadas
        7. Se implementó modalidad teletrabajo
        8. Planea contratar en los próximos 6 meses
        9. Ha reinventado su negocio a pedidos virtuales
        10. Aumento de precios de insumos y materias primas(combustibles, abarrotes, servicios públicos)
        11. Ninguna
      - El sub-campo "Afectaciones por COVID sobre las ventas", es un campo de selección MÚLTIPLE, que dará a escoger de la lista siguiente:
        1. Ingreso "0" ante la afectación de una orden sanitaria.
        2. Reducción de los ingresos entre 50%-90%
        3. Reducción de los ingresos entre 20%-50%
        4. Se mantuvieron dentro de lo esperado
        5. Aumentaron
        6. Ninguna
        7. NS/NR
  - **Medidores eléctricos**. Cantidad de medidores(num), Observaciones(texto)





  - Solo puede haber un registro de cada variable, por cada edificio. Esto no aplica para "Uso de suelos y...", Esta variable puede tener uno o más registros por cada edificio. Recalcar que cada edificio que se vaya a encuestar o auditar, debe tener un y solo un registro por cada variable para poder ser guardado en la base de datos, excepto la variable que ya se mencionó, la cual debe tener AL MENOS 1 registro, pudiendo tener mas de 1.
  - Se debe guardar la información de edición de cada registro en una lista que almacene en cada fila: `id`, `fecha y hora` y `tipo`, este último dirá que tipo de variable se registró, por ejemplo, "Terreno".
  - En la lista de información de edición de los registros, que se menciona anteriormente, se debe poder hacer click y acceder al registro elegido, aqui se podrá nuevamente el registro, o eliminarlo, quitándolo también de la lista de registros hechos








# PREGUNTAS PARA LA TUTORA

1. Qué ocurre en caso de que haya 1 edificio en construcción en la parcela, pero ya existan edificios en la parcela además del mismo? Que ocurre si hay más de uno en construcción? Material de la fachada en caso de que haya uno o más edificios en construcción, podría ser rellenado normalmente, o debería tener algún codigo especifico?
2. Terreno lleva referencia a un Edificio específico?
3. Como le proporcionarán a la app la base de datos con información sobre los negocios en la variable "Uso de suelo y..."





# Mejoras posibles
Validación de Registros,
Sugerencia en el sub-campo "Observaciones" de las variables: Por ejemplo en la variable "Edificación" podría aparecer por defecto (Placeholder)"Predio encajonado".


## Detalles interfaz grafica
- Al cambiar el numero de predio, debera reaccionar el formulario completo y cambiar en consecuencia.
  - En caso de que esté a medias, alguno de los 3, propiedad, Edificio, o el propio Predio, se debera preguntar si guardar los cambios actuales o no.
- al seleccionar una entidad(opcion de edicion) ya sea de edificio o de propiedad, el resto del formulario cambiara en consecuencia
  - Para el caso de edicion de una Propiedad, se muestran los datos de dicha tupla y se muestra un mensaje de guardado en caso de que no se hayan guardado los datos
  - Para el caso de un edificio, en caso de que se este rellenando un edificio o una propiedad, se mostrara un mensaje de guardado, en caso de que ambos formularios esten guardados, se agregara un nuevo edificio sin mas. Ambos casos terminaran cambiando la lista de las propiedades ya que se cambia de edificio.
- tendran un icono de `agregar` a la izquierda de las entidades que sea para crear una nueva instancia de formulario
- en caso de que se tenga rellenado algun campo, o sea, que el formulario este a medio rellenar, y se presione el boton de `agregar`, saldra una ventana emergente preguntando si quieren salvar los cambios
- En caso de que se hayan salvado los cambios, no se preguntara nada
  - En caso de que este vacio el formulario, tambien se aplica para el mismo caso
- Hay que tener en cuenta el caso de que se esta rellenando una nueva propiedad y se agrega un edificio, con la propiedad a medias, o se cambia el numero del predio con un edificio a medias, o una combinacion de ambas
- Al hacer click sobre el boton de `agregar` y no se haya rellenado nada, o sea que el formulario este vacio, no se hara nada. Esto se cumple tanto para Propiedad como para Edificio




### IMPORTANTE!!!
EN CASO DE QUE SE TENGA UN MENSAJE DE GUARDADO AL MODIFICAR ALGUN FORMULARIO CON DATOS AUN NO SALVADOS, Y SE INTENTE VALIDAR EL FORMULARIO Y NO SE PUEDA, NO SE SALVAN LOS CAMBIOS HASTA QUE ESTO OCURRA.

En caso de editar el numero del edificio en el formulario de edificio o editar el numero de local en el formulario de Propiedad, debemos modificar tambien no solo la tupla que corresponde al nuevo identificador en la base de datos, sino tambien el diccionario almacenado como variable global del Formulario correspondiente.

Cuando se quita el checkmark de "Localizacion" en el formulario de Edificio, o "Numero de Edificio" en el formulario de Propiedad nos tenemos que secciorar de cambiar la info en la tabla. En el caso de un Propiedad cambiada de edificio, no hay problema, solo se cambia el id y ya, pero para el caso de cambiar un edificio de Localizacion, tendremos que cambiar todas las propiedades de localizacion. Aqui hay que tener en cuenta que puede que haya un edificio en la nueva localizacion con el mismo numero, por ende hace falta chequear esto y enviar un mensaje de advertencia. Importante cambiar informacion en base de datos, pero tambien en el diccionario local de AMBAS tablas.




- Al no ejecutarse la validacion de los campos de formulario que estan inhabilitados, esto podemos aprovecharlo para cambiar en los metodos de validacion de los campos como "Localizacion" en predio, en edificio y en propiedad, o "noEdificio" en edificio y en propiedad, o "noLocal" en Propiedad



### No tan importante
- Al validar el formulario, no se ejecutan los metodos de validacion de los campos que no estan `enabled`, por lo tanto, por ejemplo, en el caso de la "Localizacion", que en varios formularios esta desabilitada pero no porque no se debe validar, sino porque es inusual cambiarla, y para evitar confusiones se inhabilita, se debria validar manualmente