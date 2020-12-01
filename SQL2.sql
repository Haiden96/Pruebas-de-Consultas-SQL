--EXEC Rep_movimientos_cah_dpf_tj_CAP '06-10-2020',0,103,''

alter procedure Rep_movimientos_cah_dpf_tj_CAP
              ( @I_fecha_proceso    smalldatetime,
                @I_Usuario          int    = 0,
                @I_agencia          int    = 0,
                @I_Indicador        char(1)= '',
                @I_server_origen    tinyint=0,  --Sificon(principal), 1=Sificon(Lectura)
                @O_error_msg        varchar(300)= '' output)
with encryption
as
/**************************************************************************************************************/
/*    DESCRIPCIÓN   : Este reporte muestra los movimientos efectuados en agencia y por usuario según filtro   */
/*    OBSERVACIONES : RD-7314 I                                                                               */
/*    REV.CALIDAD   : OK                                                                                      */
/**************************************************************************************************************/
-- region variables
declare @F_contestado       tinyint,
		@F_string           char(70),
		@P_condicion        varchar(400),
		@F_string1          char(120),
		@F_importe          decimal(13,2),
		@F_sistema          smallint, 
		@F_moneda1          tinyint,
		@F_nro_cah          int,
		@F_Cod_Tran         int,
		@F_Descripcion      varchar(45),
		@F_Descrip_dpf      varchar(40),
		@F_usuario_ful      varchar(8),
		@F_comilla          char(1),
		@F_fecha            char(12),
		@F_Total_Comp       int, 
		@F_num              int,
		@F_comprobante      decimal(12), 
		@F_comprobante_via  decimal(12), 
		@F_comprobante_Aux  decimal(12), 
		@F_sistema_via      smallint,
		@F_nro_cuenta       decimal(12),
		@F_agencia          smallint,
		@F_usuario          int,
		@F_importe_ope      decimal(13,2),
		@F_Saldo            decimal(13,2),
		@F_importe_via      decimal(13,2),
		@F_moneda           char(3),
		@F_indicador        char(1),
		@F_nombcorto        varchar(15),
		@F_error_exec       smallint,
		@F_rowcount         smallint,
		@F_moneda2          tinyint,
		@F_cliente          int,
		@F_Criterio         varchar(500),
		@F_CriterioX        varchar(500),
		@F_Criterio1        varchar(500),
		@F_Criterio_trn     varchar(500),
		@F_sec              smallint,
		@F_Tipo_mov         Tinyint,
		-----agregado por cristina ---
		@F_Criterio2        varchar(500), 
		@F_Criteriodpf      varchar(500),
		@F_Criterio3        varchar(500), 
		@F_Criterio4        varchar(500), 
		@F_sec2             smallint,
		@F_cantidad         smallint,
		@F_cliente1         int,
		@F_cadenacliente    varchar(800),
		@F_nombreful        varchar(100),
		@F_nombre_corto     varchar(10),                 
		@F_ok               varchar(25),
		@F_ok1              varchar(25), 
		@F_cantidad2        int,                 
		@F_usuario1         int,
		@F_negacion         varchar(50),  
		@F_cmodi            int,
		@F_cnuevo           int,
		@F_Condicion_doc    varchar(500),
		@F_cadindicador     varchar(30), 
		@f_fraccion         smallint,
		--- MOVIMIENTO DPF
		@F_Cod_Tran_aux     int,
		@F_SubTotal_Comp    int, 
		@F_Capital          decimal(13,2),
		@F_mto_ahorro       decimal(13,2),
		@F_mto_efectivo     decimal(13,2),
		@F_mto_contable     decimal(13,2),
		@error_exec         smallint,
		@F_Encabezado       varchar(200),
		@F_Detalle          varchar(200),
		@F_Interes          decimal(13,2),
		@F_SubTotal_int     decimal(13,2),
		@F_SubTotal_cap     decimal(13,2),
		@F_SubTotal_ef      decimal(13,2),
		@F_SubTotal_con     decimal(13,2),
		@F_SubTotal_ah      decimal(13,2),
		@F_Total_int        decimal(13,2),
		@F_Total_cap        decimal(13,2),
		@F_Total_ef         decimal(13,2),
		@F_Total_con        decimal(13,2),
		@F_Total_ah         decimal(13,2),
		@F_Plazo            smallint,
		@F_Lapso            smallint,
		@F_codigo_cliente   int,
		@F_sigla_moneda     varchar(6),
		@F_tasa             DECIMAL(8,4),
		@F_Fecha_proceso    smalldatetime,
		@F_agencia_us       smallint,
		@F_ok2              varchar(100),
		@F_nombcorto1       varchar(20),
		@F_cant             int,
		@F_estado           varchar(50),
		@F_sec_alta         int,
		@F_encabezado_rd_1781	tinyint=0, --Correccion en reporte de movimiento de cuentas (VISTA Antes y Despues del cambio)
		@F_banco_dest           varchar(10), 
		@F_sub_banco_dest       varchar(10), 
		@f_tipo_cuenta          smallint,
		@f_monto_conver         decimal(13,2), 
		@f_nro_autorizacion     int,
		@f_tasa_preferencial    decimal(13,2),
		@f_comision             decimal(13,2),
		@f_itf                  decimal(13,2), 
		@f_moneda_orig          smallint,
		@f_itf_conver           decimal(13,2),
		@f_ci_nit               varchar(25),
		@f_nro_cuenta_dest      varchar(25),
		@f_codError             char(4),
		@f_nro_cuenta_orig      varchar(25),
		@f_codRespuesta         varchar(10),
		@F_fecha_desde_log      datetime,
		@F_observacion_error    varchar(200),
		@F_retiene_iva          tinyint,
		@F_fecha2               smalldatetime,
		@F_tipo_lectura         tinyint,
		@F_string2              varchar(20),
		@RowCount				as integer=0,
		@f_total_consulta       int,
		@f_id_consulta          decimal(20),
		@f_identificacion       varchar(14),
		@f_complemento          varchar(10),
		@f_nombre               varchar(40),
		@f_primer_apellido      varchar(30),
		@f_segundo_apellido     varchar(30),
		@f_fecha_nac            varchar(10),
		@f_funcionario          int,
		@f_nombre_funcionario   varchar(30),
		@f_subzona              decimal(9),
		@f_nombre_agencia       varchar(100),
		@f_sucursal             char(2),
		@f_nombre_sucursal      varchar(50),
		@f_autorizador          int,
		@f_nombre_autorizador   varchar(30),
		@f_consultado_segip     char(2),
		@f_nombre_estado        varchar(20),
		@f_descripcion_tipo     varchar(50),
		@f_condicion_aux        varchar(800),
		@f_existe_valor         int,
		@f_age_usu_filtro       int,
		@F_fecha_corte_fslnet   smalldatetime,
		@z_fecha_proceso        smalldatetime,
		@F_maxsec               int,
		@F_count                int,
		@sql                        nvarchar(4000),      
		@paramDefinition            nvarchar(2000),
		@F_nombre_servidor_reporte  varchar(500),
		@F_estado_servidor_reporte  tinyint,
		@F_EnmascararTjt        int=0,
		@F_query				varchar(max)=''
-- endregion                 
-----------------------------------------------------------------------------------
--  Titulo GENERALES  
-----------------------------------------------------------------------------------
set nocount on
SET TRANSACTION  ISOLATION LEVEL READ UNCOMMITTED
set @z_fecha_proceso  = @I_fecha_proceso
if @I_Usuario=0 and @I_agencia=0 
   begin
     set @O_error_msg = 'Favor ingresar filtro de usuario o agencia para generar el reporte. Verifique...'
     goto error
   end
-- region ejecuta_en_otro_servidor
/**************************************************************************************/
/*   CONTROL PARA EJECUTAR REPORTE EN OTRO SERVIDOR                                   */
/**************************************************************************************/
 if exists (select tabla
			from pam_tablas
            where tabla = 726
				and descripcion = 'Rep_movimientos_cah_dpf_tj_CAP'
                and cod_rel = 1
                and indicador = 'A'
                and fecha_proceso_hasta = '01-01-2050')
begin 
	select  @F_nombre_servidor_reporte = descripcion,  --nombre del servidor y base de datos
			@F_estado_servidor_reporte = cod_rel       --0=leer reporte del servidor princial, 1=leer reporte de otro servidor
    FROM pam_tablas with(nolock)
	where tabla = 110
		and codigo=11   --
		and fecha_proceso_hasta='01-01-2050'
		and indicador = 'A'

 --llamar a otro servidor
if @I_server_origen = 0 and @F_estado_servidor_reporte = 1
   begin
   begin try
   --leer de pam tablas el nombre del servidor y base de datos
   set @F_nombre_servidor_reporte = @F_nombre_servidor_reporte+'Rep_movimientos_cah_dpf_tj_CAP'
   SET @paramDefinition = ' @I_fecha_proceso smalldatetime, '+
                          ' @I_Usuario int=0, '+
                          ' @I_agencia int=0, '+
                          ' @I_Indicador char(1)='''', '+
                          ' @I_server_origen tinyint=0, '+
                          ' @O_error_msg varchar(300)='''' OUTPUT'
   Set @sql = @F_nombre_servidor_reporte + N' @I_fecha_proceso, @I_Usuario, @I_agencia, @I_Indicador, @I_server_origen, @O_error_msg output '

   EXEC @F_error_exec = sp_executesql @sql, @paramDefinition, 
           @I_fecha_proceso       = @z_fecha_proceso,
           @I_Usuario             = @I_Usuario,
           @I_agencia             = @I_agencia,
           @I_Indicador           = @I_Indicador,
           @I_server_origen       = 1,  --Sificon(principal), 1=Sificon(Lectura)
           @O_error_msg           = @O_error_msg output
     
   if @F_error_exec<>0 
      begin
      set @O_error_msg = @O_error_msg
      goto error
      end

   end try                  
   begin catch
        set @O_error_msg = isnull(@O_error_msg,'Error')+ '; Err['+ltrim(str(error_number()))+']Msj['+error_message()+']Lin['+ltrim(str(error_line()))+']'
        goto Error
   end catch                                                       

   goto linea_salir_procedimiento
   end
/**************************************************************************************/

-- endregion
-- region inicializar_variales

    select nombre_reporte = 'movimientos_cap.r',91
    select linea_texto='¬5'
    set @f_string = ' AL ' + cast(CONVERT (char, @z_fecha_proceso, 5) as char(8))
    set @F_comilla = char(39)
    set @F_fecha = @F_comilla  +  convert(char(10),@z_fecha_proceso,105) + @F_comilla 
    set @F_usuario = isnull((select cliente
                               from climst_usuario
                              where nombcorto = system_user
                                and indicador = 'A'), 0)
                                
   set @F_fecha_desde_log = getdate()
   --- RD-2416 (BVC)
   if (@F_usuario=0)
   begin
     set @O_error_msg = 'El usuario no existe. Verifique...'
     goto error
   end
   --- FIN RD-2416 (BVC)
  select @F_EnmascararTjt=dbo.fn_tjt_Permiso_enmascTarjeta(@F_usuario, 1)

  select --@F_tipo_usuario = tipo_usuario ,
         @F_agencia_us   = agencia
      from climst_usuario 
   where cliente = @F_usuario
      and indicador ='A'
  exec @F_error_exec=proc_GLB_leer_fecha_datos_historicos 
                      @I_sistema        = 200,
                      @I_fecha_inicio   = @z_fecha_proceso,
                      @I_fecha_fin      = @z_fecha_proceso,
                      @O_fecha          = @F_fecha2       output,
                      @O_tipo_lectura   = @F_tipo_lectura output,
                      @O_string         = @F_string2      output,
                      @O_error_msg      = @O_error_msg    output
			IF @@error <> 0 
						BEGIN
								SET @O_error_msg ='Error en exec proc_GLB_leer_fecha_datos_historicos.'
								GOTO Error
						END   
			IF @F_error_exec <> 0 GOTO Error
 
-- endregion 
-- region titulo

-------------------------------------------------------------------------------------
    If ISNULL(@I_agencia,0) = 0 and isnull(@I_usuario,0)=0
       set @F_string1 = 'MOVIMIENTO CONSOLIDADO'
    Else 
       If @I_agencia > 0 
          set @F_string1 = 'MOVIMIENTO DE AGENCIA ' + isnull(cast((SELECT sigla from pam_agencia
                                                               where agencia   = @I_agencia
                                                                 and indicador ='A') as char(45)),'')
       Else
          set @F_string1 = 'MOVIMIENTO DE AGENCIA ' + isnull(cast((SELECT sigla from pam_agencia
                                                               where agencia   = @F_agencia_us
                                                                and indicador ='A') as char(45)),'')
    exec sp_titulos
         @I_ancho_reporte       = 120,
         @I_nro_pagina          = 1,
         @I_saltar_pagina       = 0,
         @I_nombre_reporte      = 'movimientos_cap.r',
         @I_titulo2             = @F_string1,
         @I_titulo3             = @f_string
 
-- endregion                 
-- region Tablas_Temporales
  --XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  --      TABLA TEMPORAL PARA GENERAR EL REPORTE COMPLETO
  --XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  create table #tabla_reporte  (id int identity(1,1) primary key (id),                               
                                tipo tinyint INDEX ix1 NONCLUSTERED,
                                subtipo tinyint INDEX ix2 NONCLUSTERED,
                                visible tinyint INDEX ix3 NONCLUSTERED,
                                linea varchar(max))  
  --Tabla temporal para cargar desde procedimientos almacenados  
  declare @tablaTemp as table (id int identity(1,1) primary key (id),                                                               
                               linea varchar(max))  

  declare @tablaTempTrans as table (id int identity(1,1) primary key (id),                                                             
                                linea varchar(max),                                  
                                fecha_proceso smalldatetime,
                                cliente int,
                                comprobante int, 
                                concepto smallint)        
		declare @tb_temporal_cursor table (
				                            id int identity(1,1) primary key (id),
                                comprobante decimal(12,0),
                                sec smallint,
                                nro_cuenta varchar(25),
                                saldo decimal(12,2),
                                cod_tran smallint,
                                agencia smallint,
                                sistema_via smallint,
                                comprobante_via decimal(12,0),
																																importe_ope    decimal(13,2),
																																moneda_via tinyint,
																																importe_via decimal(13,2),
																																usuario int,
																																indicador char(1),
																																nit varchar(14),
																																cliente int,
																																nombre_corto varchar(30),
																																descripcion char(45),
																																moneda varchar(6),
																																comprobante_aux decimal(12,0),
																																total_comp int,
																																contestado tinyint)        
declare @tb_temporal_dpf table (
				                            id          int identity(1,1) primary key (id),
                                comprobante decimal(12,0),
                                cod_tran    smallint,
                                usuario     int,
                                nro_cuenta  varchar(25),
                                fraccion    smallint,
                                capital     decimal(13,2),
                                interes     decimal(13,2),
                                indicador   char(1),
                                num         tinyint,
                                ci_nit      varchar(25),
                                retiene_iva tinyint,
                                Descrip_dpf varchar(40))
declare @tb_temporal_ach table (
				                            id             int identity(1,1) primary key (id),                                
                                sub_banco_dest varchar(10), 
                                banco_dest     varchar(10),  
                                tipo_cuenta    smallint,
                                comprobante    decimal(12), 
                                cliente        int,
                                nro_cuenta_orig varchar(25), 
                                nro_cuenta_dest varchar(25), 
                                Saldo           decimal(13,2), 
                                comision        decimal(13,2), 
                                moneda          char(3), 
                                estado          int, 
                                usuario         int, 
                                codError        char(4),
                                codRespuesta    varchar(10),
                                ci_nit          varchar(25))   
                            
 declare @tb_temporal_cmx table (
				                            id             int identity(1,1) primary key (id),        
                                usr_nombcorto  varchar(8),
                                nro_giro       int,
                                cliente        int,
                                monto_giro     decimal(13,2),
                                comprobante    decimal(12),
                                sigla          varchar(6)   ,
                                indicador      char(1) ,
                                estado_gir_desc varchar(10)) 
 declare @tb_temporal_tjt table (
				                            id             int identity(1,1) primary key (id), 
                                nro_tarjeta    decimal(16),
                                nombrecliente  varchar(50), 
                                nombre_usuario varchar(25), 
                                sec_alta       int)

create table  #temp_tabla_reporte( id int identity(1,1) primary key (id)
                                 , nombcorto nvarchar(20)
                               		, nro_cuenta int
                               		, nombre_ful nvarchar(100)
                               		, siglab nvarchar(20)
                               		, monto decimal(13,2)
                               		, sigla nvarchar(6)
                               		, agencia smallint
                               		, sec  int
                               		, bloqueo tinyint INDEX ix1 NONCLUSTERED
                               		, usuario int)     

  create table #temp_tabla_custodio(  id int identity(1,1) primary key (id)
                                    , nombcorto nvarchar(30)
                                    , nro_cuenta int
                                    , nro_solicitud int
                                    , cliente_entrega nvarchar(100)
                                    , documento_entrega nvarchar(100)
                                    , sigla nvarchar(300)
                                    , fecha_proceso smalldatetime
                                    , fecha_proceso_hasta smalldatetime
                                    , usr_digitada int
                                    , agencia_digitada smallint
                                    , fecha_digitada datetime
                                    , agencia_entrega smallint
                                    , usr_en_custodio int
                                    , fecha_en_custodio datetime
                                    , usr_entrega_cliente int
                                    , fecha_entrega_cliente datetime
                                    )        

		CREATE TABLE #temp_bloqueo_cct(nombcorto nvarchar(30)
                      									, nro_cuenta int
                      									, nombre_ful nvarchar(100)
                      									, siglab nvarchar(20)
                      									, monto decimal(13,2)
                      									, sigla nvarchar(6)
                      									, agencia smallint
                      									, usuario int
                      									, fecha_proceso smalldatetime
                      								 , bloqueo tinyint INDEX ix1 NONCLUSTERED
                      									, indicador char(1)
                      								)

-- endregion								 
-- region movimiento_clientes
--------------------------------------------------------------------------------------------------
-- MOVIMIENTOS DE CLIENTES   
---------------------------------------------------------------------------------------------------
     
     --CLIENTES  Tipo=1 Subtipo=0,1 Visible=1
     
     insert into #tabla_reporte
     Select 1,0,1,Linea_texto           = ''
     union all Select 1,0,1,Linea_texto = ''
     union all Select 1,0,1,Linea_texto = ''
     union all Select 1,0,1,Linea_texto = '----------------------------------------------------------------------------------------------------------------------------------' 
     union all Select 1,0,1,Linea_texto = 'MOVIMIENTOS DE CLIENTE         '
     union all Select 1,0,1,Linea_texto = '----------------------------------------------------------------------------------------------------------------------------------' 
---------------------------------------------------------------------------------------------------
-- CARGADO DE FIRMAS Y FOTOS
---------------------------------------------------------------------------------------------------
   set @P_condicion = REPLACE (@F_Criterio,'a.usuario','b.usuario')
   
   insert into #tabla_reporte
   Select 1,1,1,Linea_texto           = '-------------------------------------------------------------' 
   union all Select 1,1,1,Linea_texto = '###                  DATOS DEL CLIENTE                  ###  '
   union all Select 1,1,1,Linea_texto = '-------------------------------------------------------------' 
   union all Select 1,1,1,Linea_texto = '----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'  
   union all Select 1,1,1,Linea_texto = 'USUARIO     CÓDIGO  CLIENTE                                        NUEVO?       MODIFICADO?      FOTOS      FIRMA      HUELLA     ALERTA    FASSILNET  DETALLE DE MODIFICACIÓN           ESTADO      '
   union all Select 1,1,1,Linea_texto = '                                                                                               CARG/AUT    CARG/AUT    CARG/AUT  CEL/MAIL    CEL/MAIL   DATOS/DIRECCIÓN'
   union all Select 1,1,1,Linea_texto = '----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------' 
-----------------------------------------------------------------------------------
--  Creando tabla temporal para cliente
-----------------------------------------------------------------------------------    
    declare @tb_temporal table (id int identity(1,1) primary key (id),
                                usuario int INDEX ix1 NONCLUSTERED,
                                tipo tinyint,
                                cliente int INDEX ix2 NONCLUSTERED,
                                nombre_ful varchar(100),
                                nombre_corto varchar(10) INDEX ix3 NONCLUSTERED,
                                modifica_cliente varchar(20),
                                ok varchar(25),
                                esta tinyint)
                                
   declare @tb_temporal2 table (id int identity(1,1) primary key (id),
                                usuario int INDEX ix1 NONCLUSTERED,
                                tipo tinyint,
                                cliente int INDEX ix2 NONCLUSTERED,
                                nombre_ful varchar(100),
                                nombre_corto varchar(10) INDEX ix3 NONCLUSTERED,
                                modifica_cliente varchar(20),
                                ok varchar(25),
                                esta tinyint)  

   declare @tb_temporal3 table (id int identity(1,1)primary key (id),
                                cliente int,
                                usuario int,
                                nombre_corto varchar(10),
                                nombre_ful varchar(100))  
	declare @temp_tabla as table (
																															usuario int,
																															cliente int,
																															nombre_ful	nvarchar(100),
																															nombrecorto nvarchar(30),
																															indicador char(1),
																															agencia smallint,
																															tipo_persona tinyint INDEX ix1 NONCLUSTERED, 
																															nombre varchar(100)INDEX ix2 NONCLUSTERED,
																															nuevo tinyint INDEX ix3 NONCLUSTERED,
																															fecha_apertura smalldatetime,
																															codigo_campo int INDEX ix4 NONCLUSTERED)
-----------------------------------------------------------------------------------
--  CRITERIOS DE CLIENTE
-----------------------------------------------------------------------------------                                 
    set @F_CriterioX = 'b.cliente§' +case @I_Usuario when 0 then '' 
                                   else ltrim(str(@I_Usuario))end+'¶'
                      +'b.agencia§'+ case @I_agencia when 0 then '' 
                                      else ltrim(str(@I_agencia))end+'¶'
    exec @F_error_exec=Construct_GLB
                       @I_mostrar    = 'N',
                       @IO_construct = @F_CriterioX  output,
                       @O_error_msg  = @O_error_msg output
    IF @@error <> 0 
       BEGIN
       SET @O_error_msg ='Error al ejecutar Construct_GLB.'
       GOTO Error
       END    
				IF @F_error_exec <> 0 GOTO Error 
    set @F_Criterio2 = 'c.cliente§' +case @I_Usuario when 0 then '' 
                                   else ltrim(str(@I_Usuario))end+'¶' 
                      +' c.agencia§'+ case @I_agencia when 0 then '' 
                                     else ltrim(str(@I_agencia))end+'¶'                                                                                                                                                                                                                                         
    exec @F_error_exec=Construct_GLB
                       @I_mostrar    = 'N',
                       @IO_construct = @F_Criterio2  output,
                       @O_error_msg  = @O_error_msg output
    IF @@error <> 0 
       BEGIN
       SET @O_error_msg ='Error al ejecutar Construct_GLB.'
       GOTO Error
       END                                          
				IF @F_error_exec <> 0 GOTO Error                                      
-----------------------------------------------------------------------------------
--  Insertando los campos de cliente
-----------------------------------------------------------------------------------                                
    if @z_fecha_proceso < '08-12-2011'
       begin
       insert into @tb_temporal   
       exec ('select linea_texto = a.usuario,'+
                                  '1,'+
                                 ' a.cliente,'+
                                 ' a.nombre_ful,'+
                                 ' b.nombcorto,'+ 
                                 ' (case when convert(char(10),a.fecha_apertura,105) =  ' + @F_fecha + ' 
                                        then space(1)+''SI''+space(16) else space(17)+''SI'' end),'+
                                 ' ''DATOS'' ,0'+           
                            ' from climst_cliente as a, '+
                                 ' climov_usuario as b '+
                           ' where '+@F_CriterioX+
                             ' and a.fecha_proceso = '+@F_fecha+  
                             ' and a.indicador in (''A'',''P'')'+
                             ' and a.usuario =  b.cliente'+
                             ' and b.indicador = ''A'' '+           
                             ' and '+@F_fecha+ ' between b.fecha_proceso and b.fecha_proceso_hasta '+   
       'union select linea_texto = a.usuario,'+
                                  '1,'+
                                 ' b.cliente,'+
                                 ' b.nombre_ful,'+
                                 ' c.nombcorto,'+ 
                                 ' (case when convert(char(10),b.fecha_apertura,105) =  ' + @F_fecha + ' 
                                        then space(1)+''SI''+space(16) else space(17)+''SI'' end),'+
                                 ' ''DATOS'' ,0'+  
                            ' from climst_persona as a WITH (NOLOCK), '+
                                 ' climst_cliente as b WITH (NOLOCK),'+
                                 ' climov_usuario as c  WITH (NOLOCK)'+
                           ' where '+@F_Criterio2+
                            '  and a.fecha_proceso = '+@F_fecha+ 
                            '  and a.indicador = ''A'''+
                            '  and a.cliente = b.cliente  '+
                            '  and a.usuario = c.cliente '+
                            '  and b.fecha_proceso_hasta = ''01-01-2050''  '+ 
                            '  and b.indicador in (''A'',''P'')'+
                            '  and c.indicador = ''A'' '+
                            '  and a.fecha_proceso  between c.fecha_proceso AND c.fecha_proceso_hasta '+                         
       'union select linea_texto = a.usuario,'+
                                  '1,'+
                                 ' b.cliente,'+
                                 ' b.nombre_ful,'+
                                 ' c.nombcorto,'+ 
                                 ' (case when convert(char(10),b.fecha_apertura,105) =  ' + @F_fecha + ' 
                                        then space(1)+''SI''+space(16) else space(17)+''SI'' end),'+
                                 ' ''DATOS'' ,0'+ 
                            ' from climst_adicionalPersona as a WITH (NOLOCK), '+
                                 ' climst_cliente as b WITH (NOLOCK),'+
                                 ' climov_usuario as c  WITH (NOLOCK)'+   
                           ' where '+@F_Criterio2+
                            '  and a.fecha_proceso = '+@F_fecha+ 
                            '  and a.indicador = ''A'' '+
                            '  and a.cliente = b.cliente '+
                            '  and a.usuario = c.cliente  '+ 
                            '  and b.fecha_proceso_hasta = ''01-01-2050'' '+
                            '  and b.indicador in (''A'',''P'') '+
                            '  and c.indicador = ''A'' '+
                            '  and a.fecha_proceso between c.fecha_proceso AND c.fecha_proceso_hasta  '+ 
       'union select linea_texto = a.usuario,'+
                                  '1,'+
                                 ' b.cliente,'+
                                 ' b.nombre_ful,'+
                                 ' c.nombcorto,'+ 
                                 ' (case when convert(char(10),b.fecha_apertura,105) =  ' + @F_fecha + ' 
                                        then space(1)+''SI''+space(16) else space(17)+''SI'' end),'+
                                 ' ''ADD EMPRESA'' ,0'+                           
                            ' from climst_adicionalEmpresa as a WITH (NOLOCK), '+
                                 ' climst_cliente as b WITH (NOLOCK),'+
                                 ' climov_usuario as c  WITH (NOLOCK)'+                          
                         ' where '+@F_Criterio2+
                            '  and a.fecha_proceso = '+@F_fecha+ 
                            '  and a.indicador = ''A'' '+
                            '  and a.cliente = b.cliente '+
                            '  and a.usuario = c.cliente  '+ 
                            '  and b.fecha_proceso_hasta = ''01-01-2050'' '+
                            '  and b.indicador in (''A'',''P'') '+
                            '  and c.indicador = ''A'' '+
                            '  and a.fecha_proceso between c.fecha_proceso AND c.fecha_proceso_hasta  '+   
       'union select linea_texto = a.usuario,'+
                                  '1,'+
                                 ' b.cliente,'+
                                 ' b.nombre_ful,'+
                                 ' c.nombcorto,'+ 
                                 ' (case when convert(char(10),b.fecha_apertura,105) =  ' + @F_fecha + ' 
                                        then space(1)+''SI''+space(16) else space(17)+''SI'' end),'+
                                 ' ''DATOS'',0'+                           
                            ' from climst_detalleEmpresa as a WITH (NOLOCK), '+
                                 ' climst_cliente as b WITH (NOLOCK),'+
                                 ' climov_usuario as c  WITH (NOLOCK)'+                          
                         ' where '+@F_Criterio2+
                            '  and a.fecha_proceso = '+@F_fecha+ 
                            '  and a.indicador = ''A'' '+
                            '  and a.cliente = b.cliente '+
                            '  and a.usuario = c.cliente  '+ 
                            '  and b.fecha_proceso_hasta = ''01-01-2050'' '+
                            '  and b.indicador in (''A'',''P'') '+
                            '  and c.indicador = ''A'' '+
                            '  and a.fecha_proceso between c.fecha_proceso AND c.fecha_proceso_hasta  '+  
        'union select distinct linea_texto = a.usuario,'+
                                  '1,'+
                                 ' b.cliente,'+
                                 ' b.nombre_ful,'+
                                 ' c.nombcorto,'+ 
                                 ' (case when convert(char(10),b.fecha_apertura,105) =  ' + @F_fecha + ' 
                                        then space(1)+''SI''+space(16) else space(17)+''SI'' end),'+
                                 ' ''DIRECCION'' ,0'+                           
                            ' from climst_direccion as a WITH (NOLOCK), '+
                                 ' climst_cliente as b WITH (NOLOCK),'+
                                 ' climov_usuario as c  WITH (NOLOCK)'+                          
                         ' where '+@F_Criterio2+
                            '  and a.fecha_proceso = '+@F_fecha+ 
                            '  and a.indicador = ''A'' '+
                            '  and a.cliente = b.cliente '+
                            '  and a.usuario = c.cliente  '+ 
                            '  and b.fecha_proceso_hasta = ''01-01-2050'' '+
                            '  and b.indicador in (''A'',''P'') '+
                            '  and c.indicador = ''A'' '+
                            '  and a.fecha_proceso between c.fecha_proceso AND c.fecha_proceso_hasta  ') 
    end
    else
    begin       
       insert into @temp_tabla  
       exec ('
							SELECT 
               a.usuario
             , b.cliente
             , b.nombre_ful
             , c.nombcorto
             , b.indicador
             , c.agencia
             , b.tipo_persona
             , d.nombre
             , a.nuevo
             , b.fecha_apertura
             , d.codigo_campo
             FROM clitrn_cliente a
              inner join  climst_cliente b on a.cliente= b.cliente
             	and a.indicador=''A''
              and a.fecha_proceso= '+@F_fecha+
             'and a.fecha_proceso between b.fecha_proceso and b.fecha_proceso_hasta
             	inner join  climov_usuario c on c.cliente = a.usuario
             	and a.fecha_proceso between c.fecha_proceso and c.fecha_proceso_hasta
             	and c.indicador=''A''
             	inner join  pamcli_campos d on a.codigo_campo = d.codigo_campo
             	and d.indicador=''A''
             	and d.estado=''A''
             	and d.tipo1 =1
             	where '+@F_Criterio2
				)

		insert into @tb_temporal  
			select distinct
				linea_texto =  a.usuario
							, '1'
							, a.cliente
							, a.nombre_ful
							, a.nombrecorto
							, (case when convert(char(10),a.fecha_apertura,105) = @z_fecha_proceso  
									then space(1)+'SI'+space(16) 
									else space(17)+'SI' 
								end)
							, 'REGISTRO'
							, 0
			from @temp_tabla a
			WHERE     a.indicador    = 'A'
					and a.tipo_persona = 1
					and a.nombre  in ('climst_cliente','climst_persona','climst_adicionalPersona','climst_detalleEmpresa')
					and a.nuevo = 1 

		union all select distinct
			linea_texto =	b.usuario
							, '1'
							, b.cliente
							, b.nombre_ful
							, b.nombrecorto
							, (case when convert(char(10),b.fecha_apertura,105) = @z_fecha_proceso  
									then space(1)+'SI'+space(16) 
									else space(17)+'SI' 
								end)
							, 'REGISTRO'
							, 0
			from @temp_tabla b
			where   b.indicador='A'
					and b.tipo_persona <> 1
					and   b.nombre in ('climst_cliente','climst_adicionalPersona','climst_detalleEmpresa')
					and   b.nuevo  = 1

	union all select distinct
		linea_texto =  c.usuario
	               , '1'
				, c.cliente
				, c.nombre_ful
				, c.nombrecorto
				, space(17)+'SI' 
	
				, 'MODIF/REG'
				, 0

	from @temp_tabla c
	where c.indicador='I'
		and c.nombre in ('climst_cliente','climst_persona','climst_adicionalPersona','climst_detalleEmpresa')
		and c.nuevo  = 0
		and c.codigo_campo <> 59
	union all select distinct
		linea_texto =  d.usuario
					   , '1'
					, d.cliente
					, d.nombre_ful
					, d.nombrecorto
					, space(17)+'SI' 
			
					, 'APROBACIÓN'
					, 0
		from @temp_tabla d	
		where   d.indicador in ('A','P')
			and   d.nombre in ('climst_cliente')
			and   d.nuevo  = 0
			and   d.codigo_campo = 59

	union all select distinct
		linea_texto =  e.usuario
	               , '1'
				, e.cliente
				, e.nombre_ful
				, e.nombrecorto
				, (case when convert(char(10),e.fecha_apertura,105) = @z_fecha_proceso  then space(1)+'SI'+space(16) else space(17)+'SI' end)
				, 'DATOS'
				, 0

		from @temp_tabla e
		where   e.indicador in ('A','P')
				and   e.nombre in ('climst_cliente','climst_persona','climst_adicionalPersona','climst_detalleEmpresa')
				and   e.nuevo  = 0
		
	union all select distinct
		linea_texto =  f.usuario
					, '1'
					, f.cliente
					, f.nombre_ful
					, f.nombrecorto
					, (case when convert(char(10),f.fecha_apertura,105) = @z_fecha_proceso  then space(1)+'SI'+space(16) else space(17)+'SI' end)
					, 'ADD EMPRESA'
					, 0

		from @temp_tabla f
		where   f.indicador in ('A','P')
			and   f.nombre ='climst_adicionalEmpresa'
			and   f.nuevo  = 0
	
	union all select distinct
		linea_texto =  g.usuario
					, '1'
					, g.cliente
					, g.nombre_ful
					, g.nombrecorto
					, (case when convert(char(10),g.fecha_apertura,105) = @z_fecha_proceso  
							then space(1)+'SI'+space(16) 
							else space(17)+'SI' 
						end)
					, 'DIRECCION'
					, 0

		from @temp_tabla g
		where	g.indicador in ('A','P')
				and g.nombre in ('climst_direccion')
				and g.nuevo  = 0
	end
end

-- endregion
-- region firma_foto
-----------------------------------------------------------------------------------
--  CRITERIO DE FIRMA Y FOTO
-----------------------------------------------------------------------------------                         
    set @F_Criterio3 = 'd.cliente§' +case @I_Usuario when 0 then '' 
                                   else ltrim(str(@I_Usuario))end+'¶'+   
                       'd.agencia§' +case @I_agencia when 0 then '' 
                                      else ltrim(str(@I_agencia))end+'¶'                                                                                                                                               
    exec @F_error_exec=Construct_GLB
                       @I_mostrar    = 'N',
                       @IO_construct = @F_Criterio3  output,
                       @O_error_msg  = @O_error_msg output
    IF @@error <> 0 
       BEGIN
       SET @O_error_msg ='Error al ejecutar Construct_GLB.'
       GOTO Error
       END                                                                                                                                             
				IF @F_error_exec <> 0 GOTO Error                                                                                                                                           
-----------------------------------------------------------------------------------
--  Insertando los campos de las fotos
-----------------------------------------------------------------------------------       
    insert into @tb_temporal2 
    exec ('select linea_texto = b.usuario, '+
                               '2, '+
                               'a.cliente,'+
                               'a.nombre_ful,'+
                               'd.nombcorto,'+ 
                              ' (case when convert(char(10),a.fecha_apertura,105) =  ' + @F_fecha + ' 
                                      then space(1)+''SI''+space(16) else space(17)+''SI'' end),'+
                             ' (case when (exists(select c.cliente from  cli_imagen as c WITH (NOLOCK)
                               where c.cliente = a.cliente                                       
                                 and c.fecha_proceso =' + @F_fecha +  
                               ' and c.indicador = ''A'' '+
                               ' and c.estado  = 1 '+                                      
                               ' and tipo=1)) then ''SI  SI'' '+
                          ' When (exists(select c.cliente from  cli_imagen as c WITH (NOLOCK)
                                          where c.cliente = a.cliente                                         
                                            and c.fecha_proceso = '+ @F_fecha +  
                                          ' and c.indicador = ''A'''+
                                          ' and c.estado  = 0 '+                                       
                                          ' and tipo=1)) then ''SI  NO'' '+
                         ' else ''NO  NO'' end ),0 '+                          
                        ' from climst_cliente as a WITH (NOLOCK),
                               cli_imagen as b WITH (NOLOCK),
                               climov_usuario as d WITH (NOLOCK) '+      
                       ' where '+@F_Criterio3+                                                   
                         ' and a.cliente = b.cliente '+
                         ' and a.indicador in (''A'',''P'') '+
                         ' and b.fecha_proceso ='+ @F_fecha +   
                         ' and a.fecha_proceso_hasta=''01-01-2050'' '+
                         ' and b.fecha_proceso between d.fecha_proceso and d.fecha_proceso_hasta '+                         
                         ' and b.tipo = 1 '+
                         ' and b.indicador=''A'' '+
                         ' and d.indicador = ''A'''+
                         ' and d.cliente = b.usuario ')                                                                    
                               
-----------------------------------------------------------------------------------
--  Insertando los campos de las firmas
-----------------------------------------------------------------------------------       
    insert into @tb_temporal2 
    exec ('select linea_texto = b.usuario, '+
                               '3, '+
                               'a.cliente,'+
                               'a.nombre_ful,'+
                               'd.nombcorto,'+ 
                              ' (case when convert(char(10),a.fecha_apertura,105) =  ' + @F_fecha + ' 
                                then space(1)+''SI''+space(16) else space(17)+''SI'' end),'+        
                              '(case when (exists(select c.cliente from  cli_imagen as c WITH (NOLOCK)
                                                   where c.cliente = a.cliente                                       
                                                     and c.fecha_proceso = '+ @F_fecha +                                       
                                                  '  and c.estado  = 1 '  +                                     
                                                  '  and tipo=2)) then ''SI  SI'' ' +
                                   ' When (exists(select c.cliente from  cli_imagen as c WITH (NOLOCK)
                                                   where c.cliente = a.cliente                                         
                                                     and c.fecha_proceso = '+ @F_fecha +                                        
                                                  '  and c.estado  = 0 '+                                      
                                                  '  and tipo=2)) then ''SI  NO'''+
                                   ' else ''NO  NO'' end ),0 '+                                            
                         ' from climst_cliente as a WITH (NOLOCK),
                                cli_imagen as b WITH (NOLOCK),
                                climov_usuario as d WITH (NOLOCK) '+      
                        ' where '+@F_Criterio3+    
                          ' and a.cliente = b.cliente '+
                          ' and a.indicador in (''A'',''P'') '+
                          ' and b.fecha_proceso ='+ @F_fecha +
                          ' and b.fecha_proceso between d.fecha_proceso and d.fecha_proceso_hasta '+                                                  
                          ' and a.fecha_proceso_hasta=''01-01-2050'' '+   
                          ' and b.tipo = 2 '+                     
                          ' and b.indicador = ''A'''+                                                    
                          ' and d.indicador = ''A''  '+
                          ' and d.cliente = b.usuario ' )  
-----------------------------------------------------------------------------------
--  CRITERIO DE HUELLA
-----------------------------------------------------------------------------------
    set @F_Criterio4 = 'd.cliente§' +case @I_Usuario when 0 then '' 
                                   else ltrim(str(@I_Usuario))end+'¶'+                                    
                       'd.agencia§' +case @I_agencia when 0 then '' 
                                      else ltrim(str(@I_agencia))end+'¶'                                                                                                                                                
    exec @F_error_exec=Construct_GLB
                       @I_mostrar    = 'N',
                       @IO_construct = @F_Criterio4  output,
                       @O_error_msg  = @O_error_msg output
    IF @@error <> 0 
       BEGIN
       SET @O_error_msg ='Error al ejecutar Construct_GLB.'
       GOTO Error
       END                                                                                                                                                                                                                                                                                     
				IF @F_error_exec <> 0 GOTO Error                                                                                                                                                                                                                                                                                        
-----------------------------------------------------------------------------------
--  Insertando los campos de la huella
-----------------------------------------------------------------------------------      
    insert into @tb_temporal2 
    exec ('select distinct linea_texto =  b.usuario, ' +
                              ' 4,'+
                              ' a.cliente, '+
                              '(select nombre_ful from climst_cliente where cliente = a.cliente and indicador in (''A'',''P'') and fecha_proceso_hasta =''01-01-2050''),'+
                              ' d.nombcorto,'+ 
                              ' (case when convert(char(10),a.fecha_apertura,105) =  ' + @F_fecha + ' 
                                then space(1)+''SI''+space(16) else space(17)+''SI'' end),'+
                              ' (case when (exists(select c.cliente from  huemst_huella as c WITH (NOLOCK)
                                                                      where c.cliente = a.cliente                                      
                                                                       and c.estado  = 1)) then ''SI  SI''
                                                          When (exists(select c.cliente from  huemst_huella as c WITH (NOLOCK)
                                                                       where c.cliente = a.cliente                                                                                
                                                                       and c.estado  = 0)) then ''SI  NO''
                                                          else ''NO  NO'' end ) ,0'+
                           ' from huemst_huella as b, 
                                  climst_cliente as a, 
                                  climov_usuario as d '+
                         ' where '+@F_Criterio4+    
                           ' and b.fecha_proceso ='+ @F_fecha +
                           ' and a.cliente = b.cliente '+
                           ' and a.indicador in (''A'',''P'') '+
                           ' and a.fecha_proceso_hasta=''01-01-2050'' '+   
                           ' and d.cliente = b.usuario '+
                           ' and d.indicador = ''A'' '+
                           ' and  b.fecha_proceso between d.fecha_proceso and d.fecha_proceso_hasta ' +
                           'union select distinct linea_texto =  b.usuario, '+
                              ' 4,'+
                              ' a.cliente, '+
                              '(select nombre_ful from climst_cliente where cliente = a.cliente and indicador in (''A'',''P'') and fecha_proceso_hasta =''01-01-2050''),'+
                              ' d.nombcorto,'+ 
                              ' (case when convert(char(10),a.fecha_apertura,105) =  ' + @F_fecha + ' 
                                then space(1)+''SI''+space(16) else space(17)+''SI'' end),'+
                              ' (case when (exists(select c.cliente from  huetrn_baja as c WITH (NOLOCK)
                                                                      where c.cliente = a.cliente                                      
                                                                       and c.estado  = 1)) then ''SI  SI''
                                                          When (exists(select c.cliente from  huetrn_baja as c WITH (NOLOCK)
                                                                       where c.cliente = a.cliente                                                                                
                                                                       and c.estado  = 0)) then ''SI  NO''
                                                          else ''NO  NO'' end ) ,0'+
                           ' from huetrn_baja as b, 
                                 climst_cliente as a, 
                                 climov_usuario as d '+
                         ' where '+@F_Criterio4+    
                          ' and b.fecha_proceso ='+ @F_fecha +
                           ' and a.cliente = b.cliente '+
                           ' and a.indicador in (''A'',''P'') '+
                           ' and a.fecha_proceso_hasta=''01-01-2050'' '+   
                           ' and d.cliente = b.usuario '+
                           ' and d.indicador = ''A'' '+
                           ' and b.fecha_proceso between d.fecha_proceso and d.fecha_proceso_hasta ')                                                                                                                                              
-----------------------------------------------------------------------------------
--  Insertando los campos del telefono
-----------------------------------------------------------------------------------       
    insert into @tb_temporal2 
    exec ('select distinct linea_texto = b.usuario, '+
                               ' case when tipo_reg = 6 then 5 '+ 
                                    ' when tipo_reg = 7 then 6 '+
                                    ' when tipo_reg = 9 then 7 '+
                                    ' when tipo_reg = 10 then 8 end,'+
                               'a.cliente,'+
                               'a.nombre_ful,'+
                               'd.nombcorto,'+ 
                               '(case when convert(char(10),a.fecha_apertura,105) =  ' + @F_fecha + ' 
                                      then space(1)+''SI''+space(16) else space(17)+''SI'' end),'+
                               ' ''SI'', 0 '+                          
                        ' from climst_cliente as a WITH (NOLOCK),
                               climst_telefonos as b WITH (NOLOCK),
                               climov_usuario as d WITH (NOLOCK) '+      
                       ' where '+@F_Criterio4+                                                   
                         ' and a.cliente = b.cliente '+
                         ' and convert(char(10),b.fecha_alta,105) = '+ @F_fecha +   
                         ' and a.indicador = ''A'' '+
                         ' and a.fecha_proceso_hasta=''01-01-2050'' '+
                         ' and d.cliente = b.usuario ' +
                         ' and b.tipo_reg in (6,7,9,10) ' +
                         ' and cast(convert(char(10),b.fecha_alta,105) as smalldatetime) between d.fecha_proceso and d.fecha_proceso_hasta '+                         
                         ' and d.indicador = ''A'' ')                                                                                                                
-----------------------------------------------------------------------------------
--  Recorriendo la tabla temporal
-----------------------------------------------------------------------------------
      select @F_sec = 1, @F_cantidad =0, @F_cadenacliente = '',
             @F_cnuevo = 0, @F_cmodi = 0
    select @F_cantidad = COUNT(*)
      from @tb_temporal             
         
    while @F_sec <= @F_cantidad
          begin                              
          select @F_cliente1 = cliente,
                 @F_nombcorto = nombre_corto,
                 @F_nombreful = nombre_ful,
                 @F_ok        = modifica_cliente,
                 @F_usuario1  = usuario,
                 @F_ok2       = ok
            from @tb_temporal
           where id = @F_sec  
          if exists (select id
                       from @tb_temporal
                      where cliente = @F_cliente1
                        and usuario = @F_usuario1
                        and esta    = 0)
             begin
             set  @F_ok2 = '' 
             select @F_ok2       = @F_ok2 + OK +', '
               from @tb_temporal
              where cliente=@F_cliente1
                and usuario = @F_usuario1     
             select @F_ok2 = cast(@F_ok2 as CHAR(31)) 
             update @tb_temporal 
                set esta = 1
              where cliente = @F_cliente1
                and usuario = @F_usuario1                 
             set @F_cadenacliente = cast(@F_nombcorto as CHAR(8))+SPACE(1)+STR(@F_cliente1)+SPACE(2)+cast(@F_nombreful as CHAR(47)) + @F_ok +SPACE(5)
             if @F_ok = ' SI                '    
             set @F_cnuevo = @F_cnuevo + 1
          else
             set @F_cmodi = @F_cmodi + 1 
          if exists(select cliente from climst_cliente where cliente = @F_cliente1
                          and indicador = 'P' and fecha_proceso_hasta = '01-01-2050') 
                set @F_estado = 'PENDIENTE'
             else
               if exists(select cliente from climst_cliente where cliente = @F_cliente1
                          and indicador = 'I' and @z_fecha_proceso between fecha_proceso and fecha_proceso_hasta)
                   set @F_estado = 'SIN APROBAR'    
               if exists(select cliente from climst_cliente where cliente = @F_cliente1
                          and indicador = 'A' and @z_fecha_proceso between fecha_proceso and fecha_proceso_hasta and tipo_persona = 1 )
                   set @F_estado = 'APROBADO'   
               else                    
                   set @F_estado = ''   
---- VERIFICA SI EXISTE FOTOS                      
             if exists (select cliente
                          from @tb_temporal2
                         where cliente = @F_cliente1
                           and usuario = @F_usuario1
                           and tipo = 2) 
                 begin
                 select @F_ok1 = ok
                   from @tb_temporal2
                  where cliente = @F_cliente1
                    and usuario = @F_usuario1
                    and tipo = 2                                
                 set @F_cadenacliente = @F_cadenacliente + SPACE(5)+@F_ok1                        
                 end
             else             
                set @F_cadenacliente = @F_cadenacliente + SPACE(5)+'NO  NO'  
--- VERIFICA SI EXISTE  FIRMA             
             if exists (select cliente
                          from @tb_temporal2
                         where cliente = @F_cliente1
                           and usuario = @F_usuario1
                           and tipo = 3)
                begin
                select @F_ok1 = ok
                  from @tb_temporal2
                 where cliente = @F_cliente1
                   and usuario = @F_usuario1
                   and tipo = 3
                set @F_cadenacliente = @F_cadenacliente + SPACE(5)+@F_ok1           
                end
             else                        
                set @F_cadenacliente = @F_cadenacliente + SPACE(5)+'NO  NO'                               
--- VERIFICA SI EXISTE HUELLA              
             if exists (select cliente
                          from @tb_temporal2
                         where cliente = @F_cliente1
                           and usuario = @F_usuario1
                           and tipo = 4) 
                begin
                select @F_ok1 = ok
                  from @tb_temporal2
                 where cliente = @F_cliente1
                   and usuario = @F_usuario1
                   and tipo = 4
                set @F_cadenacliente = @F_cadenacliente + SPACE(5)+@F_ok1             
                end
             else                        
               set @F_cadenacliente = @F_cadenacliente + SPACE(5)+'NO  NO'    
--- VERIFICA SI EXISTE CELULAR ALERTA 
             if exists (select cliente
                          from @tb_temporal2
                         where cliente = @F_cliente1
                           and usuario = @F_usuario1
                           and tipo = 5) 
                begin
                select @F_ok1 = ok
                  from @tb_temporal2
                 where cliente = @F_cliente1
                   and usuario = @F_usuario1
                   and tipo = 5
                set @F_cadenacliente = @F_cadenacliente + SPACE(5)+@F_ok1             
                end
             else                        
                set @F_cadenacliente = @F_cadenacliente + SPACE(5)+'NO'  
--- VERIFICA SI EXISTE CORREO ALERTA
             if exists (select cliente
                          from @tb_temporal2
                         where cliente = @F_cliente1
                           and usuario = @F_usuario1
                           and tipo = 6) 
                 begin
                 select @F_ok1 = ok
                   from @tb_temporal2
                  where cliente = @F_cliente1
                    and usuario = @F_usuario1
                    and tipo = 6
                 set @F_cadenacliente = @F_cadenacliente +SPACE(1)+@F_ok1             
                 end
             else                        
                set @F_cadenacliente = @F_cadenacliente + space(1) +'NO'  
--- VERIFICA SI EXISTE CELULAR FASSILNET
             if exists (select cliente
                          from @tb_temporal2
                         where cliente = @F_cliente1
                           and usuario = @F_usuario1
                           and tipo = 7) 
                 begin
                 select @F_ok1 = ok
                   from @tb_temporal2
                  where cliente = @F_cliente1
                    and usuario = @F_usuario1
                    and tipo = 7
                 set @F_cadenacliente = @F_cadenacliente + SPACE(6)+@F_ok1             
                 end
             else                        
                set @F_cadenacliente = @F_cadenacliente + SPACE(6)+'NO'  
--- VERIFICA SI EXISTE CORREO FASSILNET
             if exists (select cliente
                          from @tb_temporal2
                         where cliente = @F_cliente1
                           and usuario = @F_usuario1
                           and tipo = 8) 
                 begin
                 select @F_ok1 = ok
                   from @tb_temporal2
                  where cliente = @F_cliente1
                    and usuario = @F_usuario1
                    and tipo = 8
                 set @F_cadenacliente = @F_cadenacliente + SPACE(1)+@F_ok1             
                 end
             else                        
                set @F_cadenacliente = @F_cadenacliente + SPACE(1)+'NO'  
--------------------------------------------------------------                                          
             --if @F_ok = ' SI                '                               
             --   select linea_texto = LTRIM(@F_cadenacliente)+'    '+@F_ok2+SPACE(3)+@F_estado          --SPACE(35)+@F_estado
             --else
             --   select linea_texto = LTRIM(@F_cadenacliente)+'    '+@F_ok2+SPACE(3)+@F_estado     
                insert into #tabla_reporte   
                select 1,1,1,linea_texto = LTRIM(@F_cadenacliente)+'    '+@F_ok2+SPACE(3)+@F_estado 
             end           
             
          select @F_cadenacliente = '' 
          set @F_sec = @F_sec + 1                                                
          end   
-----------------------------------------------------------------------------------                    
    insert into @tb_temporal3
    select distinct cliente, usuario, nombre_corto, nombre_ful  
    from @tb_temporal2 

    select @F_cantidad2 = max(id),
           @F_sec2      = MIN (id)
      from @tb_temporal3 --@tb_temporal2    

    select @F_cadenacliente = ''         
    set @F_negacion = space(1)+'NO'+space(14)+'NO'  
    set @F_sec2 = isnull(@F_sec2,0)
    set @F_cantidad2 = ISNULL(@F_cantidad2,0)
 
---MUESTRA TODAS LAS MODIFICACIONES DE FOTO, FIRMAS Y HUELLAS, celular y correo alerta, celular y correo fassilnet
    while @F_sec2 <= @F_cantidad2
          begin
          select @F_cliente1 = cliente,
                 @F_nombcorto = nombre_corto,
                 @F_nombreful = nombre_ful,
                 --@F_ok        = ok,
                 @F_usuario1  = usuario               
            from @tb_temporal3 --@tb_temporal2
           where id = @F_sec2                                         
          if not exists (select id
                           from @tb_temporal
                          where cliente      = @F_cliente1 -- nombre_ful   = @F_nombreful
                            and usuario      = @F_usuario1 
                            and nombre_corto = @F_nombcorto) and
             exists (select id
                       from @tb_temporal2
                      where cliente    = @F_cliente1 --nombre_ful = @F_nombreful
                        and usuario    = @F_usuario1
                        and esta       = 0)                                          
             begin                       
             set @F_cadenacliente = cast(@F_nombcorto as CHAR(8))+SPACE(1)+STR(@F_cliente1)+SPACE(2)+cast(@F_nombreful as CHAR(47)) 
             ---- VERIFICA SI EXISTE FOTOS                      
             if exists (select cliente
                          from @tb_temporal2
                         where cliente = @F_cliente1
                           and usuario = @F_usuario1
                           and tipo = 2
                           and esta = 0) 
                begin
                select @F_ok1 = ok
                  from @tb_temporal2
                 where cliente = @F_cliente1
                   and usuario = @F_usuario1
                   and tipo = 2                                                   
                set @F_cadenacliente =  @F_cadenacliente +@F_negacion+ SPACE(10)+@F_ok1                                     
                update @tb_temporal2 set esta = 1 where cliente = @F_cliente1 and usuario= @F_usuario1 and tipo = 2                
                end
             else             
                set @F_cadenacliente = @F_cadenacliente +@F_negacion+ SPACE(10)+'NO  NO'  
             ---- VERIFICA SI EXISTE FIRMAS                      
             if exists (select cliente
                          from @tb_temporal2
                         where cliente = @F_cliente1
                           and usuario = @F_usuario1
                           and tipo = 3
                           and esta = 0) 
                begin
                select @F_ok1 = ok
                  from @tb_temporal2
                 where cliente = @F_cliente1
                   and usuario = @F_usuario1
                   and tipo = 3                                
                set @F_cadenacliente = @F_cadenacliente + SPACE(5)+@F_ok1 
                update @tb_temporal2 set esta = 1 where cliente = @F_cliente1 and usuario= @F_usuario1 and tipo = 3                                    
                end
             else             
                set @F_cadenacliente = @F_cadenacliente + SPACE(5)+'NO  NO'
             ---- VERIFICA SI EXISTE HUELLAS                     
             if exists (select cliente
                          from @tb_temporal2
                         where cliente = @F_cliente1
                           and usuario = @F_usuario1
                           and tipo = 4
                           and esta = 0) 
                begin
                select @F_ok1 = ok
                  from @tb_temporal2
                 where cliente = @F_cliente1
                   and usuario = @F_usuario1
                   and tipo = 4                                
                set @F_cadenacliente = @F_cadenacliente + SPACE(5)+@F_ok1   
                update @tb_temporal2 set esta = 1 where cliente = @F_cliente1 and usuario= @F_usuario1 and tipo = 4                                  
                end
             else             
                set @F_cadenacliente = @F_cadenacliente + SPACE(5)+'NO  NO'   

--- VERIFICA SI EXISTE CELULAR ALERTA 
             if exists (select cliente
                          from @tb_temporal2
                         where cliente = @F_cliente1
                           and usuario = @F_usuario1
                           and tipo = 5) 
                begin
                select @F_ok1 = ok
                  from @tb_temporal2
                 where cliente = @F_cliente1
                   and usuario = @F_usuario1
                   and tipo = 5
                set @F_cadenacliente = @F_cadenacliente + SPACE(5)+@F_ok1     
                update @tb_temporal2 set esta = 1 where cliente = @F_cliente1 and usuario= @F_usuario1 and tipo = 5        
                end
             else                        
                set @F_cadenacliente = @F_cadenacliente + SPACE(5)+'NO'  
--- VERIFICA SI EXISTE CORREO ALERTA
             if exists (select cliente
                          from @tb_temporal2
                         where cliente = @F_cliente1
                           and usuario = @F_usuario1
                           and tipo = 6) 
                 begin
                 select @F_ok1 = ok
                   from @tb_temporal2
                  where cliente = @F_cliente1
                    and usuario = @F_usuario1
                    and tipo = 6
                 set @F_cadenacliente = @F_cadenacliente + SPACE(1)+@F_ok1     
                 update @tb_temporal2 set esta = 1 where cliente = @F_cliente1 and usuario= @F_usuario1 and tipo = 6        
                 end
             else                        
                set @F_cadenacliente = @F_cadenacliente + SPACE(1)+'NO'  
--- VERIFICA SI EXISTE CELULAR FASSILNET
             if exists (select cliente
                          from @tb_temporal2
                         where cliente = @F_cliente1
                           and usuario = @F_usuario1
                           and tipo = 7) 
                 begin
                 select @F_ok1 = ok
                   from @tb_temporal2
                  where cliente = @F_cliente1
                    and usuario = @F_usuario1
                    and tipo = 7
                 set @F_cadenacliente = @F_cadenacliente + SPACE(7)+@F_ok1   
                 update @tb_temporal2 set esta = 1 where cliente = @F_cliente1 and usuario= @F_usuario1 and tipo = 7          
                 end
             else                        
                set @F_cadenacliente = @F_cadenacliente + SPACE(7)+'NO'  
--- VERIFICA SI EXISTE CORREO FASSILNET
             if exists (select cliente
                          from @tb_temporal2
                         where cliente = @F_cliente1
                           and usuario = @F_usuario1
                           and tipo = 8) 
                 begin
                 select @F_ok1 = ok
                   from @tb_temporal2
                  where cliente = @F_cliente1
                    and usuario = @F_usuario1
                    and tipo = 8
                 set @F_cadenacliente = @F_cadenacliente + SPACE(1)+@F_ok1  
                 update @tb_temporal2 set esta = 1 where cliente = @F_cliente1 and usuario= @F_usuario1 and tipo = 8           
                 end
             else                        
                set @F_cadenacliente = @F_cadenacliente + SPACE(1)+'NO'  
                             
             insert into #tabla_reporte                                        
             select 1,1,1,linea_texto = LTRIM(@F_cadenacliente)                              
             
             select @F_cadenacliente = '' 
             end                                   
          set @F_sec2 = @F_sec2 + 1
          end  
          
    insert into #tabla_reporte          
    select 1,1,1,linea_texto = '----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'    
    union all select 1,1,1,linea_texto = 'Total General'+SPACE(48)+STR(@F_cnuevo)+SPACE(6)+STR(@F_cmodi)       
    
    
      set @RowCount=0
      select @RowCount=count(id) from #tabla_reporte where tipo =1 and subtipo=1     
      
      
      if @RowCount = 9 --Cantidad de lineas que ocupa el header(7) y footer(2)
      begin 
            --SI NO HAY REGISTROS OCULTA LAS CABECERAS DEL SUBREPORTE  
            update #tabla_reporte set  visible=0 where tipo =1 
      end

-- endregion
-- region cah

------------------------------------------------------------------------------------------------------------------
----APERTURA DE CAJA DE AHORRO
------------------------------------------------------------------------------------------------------------------   
    --CAJA DE AHORRO  Tipo=2 Subtipo=0,1 Visible=1
     
    insert into #tabla_reporte    
    Select 2,1,1,Linea_texto = ''
    union all Select 2,1,1,Linea_texto = ''
    union all Select 2,1,1,Linea_texto = '-----------------------------------------------' 
    union all Select 2,1,1,Linea_texto = '###  LISTADO DE APERTURA DE CAJA DE AHORRO  ###'
    union all Select 2,1,1,Linea_texto = '-----------------------------------------------' 
    set @F_Criterio1 = 'e.cliente§' +case @I_Usuario when 0 then '' 
                                     else ltrim(str(@I_Usuario))end+'¶'
                      +'e.agencia§'+ case @I_agencia when 0 then '' 
                                     else ltrim(str(@I_agencia))end+'¶'
    exec @F_error_exec=Construct_GLB
                       @I_mostrar    = 'N',
                       @IO_construct = @F_criterio1  output,
                       @O_error_msg  = @O_error_msg output
    IF @@error <> 0 
       BEGIN
       SET @O_error_msg ='Error al ejecutar Construct_GLB.'
       GOTO Error
       END  
				IF @F_error_exec <> 0 GOTO Error     
       
    delete from @tablaTemp  
    insert into @tablaTemp   
    exec rep_apertura_diaria_caja_ahorro
                                    @I_fecha_desde  = @z_fecha_proceso,
                                    @I_fecha_hasta  = @z_fecha_proceso,
                                    @P_condicion    = @F_Criterio1,
                                    @I_tipo         = 0 
  
   --SET @O_error_msg ='@Rowcount: '+ cast(@@ROWCOUNT as varchar(30))
   --    GOTO Error                                  
  if @@ROWCOUNT = 5
      begin 
            update #tabla_reporte set  visible=0 where tipo =2 and subtipo=1        
      end   
  else
      begin
            insert into #tabla_reporte                                    
            Select 2,1,1,linea from @tablaTemp                                     
      end
    
    
----------------------------------------------------------------------------------------------------
----  MOVIMIENTOS DE CAJA DE AHORRO
-----------------------------------------------------------------------------------------------------     
    if @I_Indicador<> ''
       set @F_cadindicador = 'a.indicador§'+@I_Indicador+'¶'
    else
       set @F_cadindicador = ''        
    set @F_Criterio = 'b.cliente§' +case @I_Usuario when 0 then '' 
                                   else ltrim(str(@I_Usuario))end+'¶'
                     +'b.agencia§'+ case @I_agencia when 0 then '' 
                                      else ltrim(str(@I_agencia))end+'¶'
                     +@F_cadindicador -- 'a.indicador§'+@I_Indicador+'¶'                                                  
    exec @F_error_exec=Construct_GLB
                       @I_mostrar    = 'N',
                       @IO_construct = @F_criterio  output,
                       @O_error_msg  = @O_error_msg output
    IF @@error <> 0 
       BEGIN
       SET @O_error_msg ='Error al ejecutar Construct_GLB.'
       GOTO Error
       END       
				IF @F_error_exec <> 0 GOTO Error      
   
   insert into #tabla_reporte    
   Select 2,2,1,Linea_texto = ''    
   union all Select  2,2,1,Linea_texto = '------------------------------------------------------------------------------------------------------------------------------------------------------------' 
   union all Select  2,2,1,Linea_texto = 'MOVIMIENTOS DE CAJA DE AHORRO'
   union all Select  2,2,1,Linea_texto = '------------------------------------------------------------------------------------------------------------------------------------------------------------' 
   union all Select  2,2,1,Linea_texto = 'USUARIO     COMPROBANTE                CLIENTE           CI/NIT    COD       TRANSACCIÓN         CUENTA          MONTO      MONEDA     PROC.CAJA   ESTADO   ' 
   union all Select  2,2,1,Linea_texto = '------------------------------------------------------------------------------------------------------------------------------------------------------------'
   if @F_tipo_lectura = 0

			insert into @tb_temporal_cursor
   exec('select a.comprobante, a.sec, a.nro_cuenta,  0 ,
                     a.cod_tran, a.agencia, a.sistema_via, a.comprobante_via,  
                     a.importe_ope, a.moneda_via, a.importe_via, a.usuario,
                     a.indicador,nit =isnull(d.nit,''0''),''0'','''','''','''',''0'',''0'',''0''
               from cahtrn_trans as a WITH (NOLOCK)
                inner join climov_usuario as b WITH (NOLOCK)
                   on a.usuario = b.cliente 
                and a.fecha_proceso between b.fecha_proceso and b.fecha_proceso_hasta 
                and b.indicador= ''A''  
                left outer join climst_clioper as c WITH (NOLOCK)
                     on c.nro_cuenta = cast(a.nro_cuenta as int)
                and c.sistema = 200 
                and c.sec = 1 
                and c.fecha_proceso_hasta = ''01/01/2050''
               left outer join climst_cliente as d WITH (NOLOCK)
                 on d.cliente = c.cliente 
                and d.fecha_proceso_hasta = ''01/01/2050''
                and d.indicador = ''A''
         where a.fecha_proceso=  '+ @F_fecha +
         ' and '+ @F_Criterio +
         ' and exists(select cod_rel
                        from pam_tablas
                       where tabla= 66
                         and cod_rel = a.cod_tran
                         and indicador = ''A''
                         and fecha_proceso_hasta = ''01-01-2050'')
           and exists (select x.comprobante
                         from cahtrn_trans as x WITH (NOLOCK)
                        where x.comprobante = a.comprobante 
                          and x.fecha_proceso=  '+ @F_fecha +
                         'and x.indicador=''A''
                          and x.sec=0
                          and exists(select cod_rel
                                       from pam_tablas
                                      where tabla= 66
                                        and cod_rel = a.cod_tran
                                        and indicador = ''A''
                                        and fecha_proceso_hasta = ''01-01-2050'')
                          and x.sistema_via in (100,200,300,601,30))  
         union all 
         select a.comprobante,0 as sec,a.nro_cuenta,a.saldo,
                (cod_traspaso +212) as cod_tran,a.agencia, 
                0 as sistema_via,0 as comprobante_via,  
                0 as importe_ope,0 as moneda_via,
                0 as importe_via,a.usuario,a.indicador,nit=''0'',''0'','''','''','''',''0'',''0'',''0''
           from cahtrn_traspaso  as a WITH (NOLOCK),
                climov_usuario as b WITH (NOLOCK)
          where a.fecha_proceso='+ @F_fecha +
           'and '+@F_Criterio+
           'and a.usuario = b.cliente
           and b.indicador = ''A''
           and a.fecha_proceso between b.fecha_proceso AND b.fecha_proceso_hasta
           order by a.comprobante ,a.sec')
						
					else 
					 begin
						insert into @tb_temporal_cursor
						exec('					 
					 select a.comprobante, a.sec, a.nro_cuenta,  0,
                    a.cod_tran, a.agencia, a.sistema_via, a.comprobante_via,  
                    a.importe_ope, a.moneda_via, a.importe_via, a.usuario,
                    a.indicador,nit =isnull(d.nit,''0''),''0'','''','''','''',''0'',''0'',''0''
               from histfassil.dbo.cahtrn_trans as a WITH (NOLOCK)
              inner join climov_usuario as b WITH (NOLOCK)
                 on a.usuario = b.cliente 
                and a.fecha_proceso between b.fecha_proceso and b.fecha_proceso_hasta 
                and b.indicador= ''A''  
              left outer join climst_clioper as c WITH (NOLOCK)
                 on c.nro_cuenta = a.nro_cuenta 
                and c.sistema = 200 
                and c.sec = 1 
                and c.fecha_proceso_hasta = ''01/01/2050''
               left outer join climst_cliente as d WITH (NOLOCK)
                 on d.cliente = c.cliente 
                and d.fecha_proceso_hasta = ''01/01/2050''
                and d.indicador = ''A''
              where a.fecha_proceso='+ @F_fecha+ 
            'and '+@F_criterio+
            'and exists(select cod_rel
                          from pam_tablas
                         where tabla= 66
                           and cod_rel = a.cod_tran
                           and indicador = ''A''
                           and fecha_proceso_hasta = ''01-01-2050'')
             and exists (select x.comprobante
                           from histfassil.dbo.cahtrn_trans as x WITH (NOLOCK)
                          where x.comprobante = a.comprobante 
                            and x.fecha_proceso='+  @F_fecha+
                           'and x.indicador=''A''
                            and x.sec=0
                            and exists(select cod_rel
                                         from pam_tablas
                                        where tabla= 66
                                          and cod_rel = a.cod_tran
                                          and indicador = ''A''
                                          and fecha_proceso_hasta = ''01-01-2050'')
                            and x.sistema_via in (100,200,300,601,30))
        union all  
         select a.comprobante,0 as sec,a.nro_cuenta,a.saldo,
                (cod_traspaso +212) as cod_tran,a.agencia, 
                0 as sistema_via,0 as comprobante_via,  
                0 as importe_ope,0 as moneda_via,
                0 as importe_via,a.usuario,a.indicador,nit=''0'',''0'','''','''','''',''0'',''0'',''0''
           from histfassil.dbo.cahtrn_traspaso  as a WITH (NOLOCK),
                climov_usuario as b WITH (NOLOCK)
          where a.fecha_proceso= '+@F_fecha +
            'and '+@F_criterio+
            'and a.usuario = b.cliente 
            and b.indicador = ''A'' 
            and a.fecha_proceso between b.fecha_proceso AND b.fecha_proceso_hasta 
         order by a.comprobante ,a.sec')
									end

update t 
   set t.nombre_corto = u.nombcorto
  from @tb_temporal_cursor t 
 inner join climst_usuario u on t.usuario = u.cliente
   and u.indicador='A'

	update t 
    set t.descripcion = p.descripcion
	  from @tb_temporal_cursor t 
	 inner join pam_codtran p on t.cod_tran = p.cod_tran
	   and p.sistema=200
	   and p.indicador='A'

	select  @F_maxsec =max(id), @F_count=min(id) from @tb_temporal_cursor
	select @F_count =isnull(@F_count,1),
        @F_maxsec =isnull(@F_maxsec,0),
	       @F_Total_Comp=0
	while (@F_count <= @F_maxsec)
	begin
  	select @F_comprobante = t.comprobante
       	, @F_agencia=t.agencia 
       	, @F_nro_cuenta =  t.nro_cuenta
       	, @F_comprobante_via = t.comprobante_via
       	, @F_nombcorto = t.nombre_corto
       	, @F_moneda2 = t.moneda_via
       	, @f_ci_nit = t.nit
       	, @F_cod_tran = t.cod_tran
       	, @F_importe_ope = importe_ope
       	, @F_indicador = indicador
       	, @F_comprobante_aux = t.comprobante_aux
    	from @tb_temporal_cursor t
    where t.id = @F_count

	  select @F_moneda = isnull(sigla,'') 
				 from pam_moneda WITH (NOLOCK)
    where moneda = @F_moneda2 
      and indicador='A'
      
   select @F_cliente = cliente --si
     from climst_clioper WITH (NOLOCK)
    where nro_cuenta=@F_nro_cuenta 
      and sec=1 
      and fecha_proceso_hasta='01-01-2050'
      and sistema = 200

  	if @F_comprobante <> @F_comprobante_aux
     	begin
       	set @F_contestado = 2
       	select @F_contestado = isnull(b.contestado,0)
         	from cajtrn_puente b
         where b.comprobante = @F_comprobante
           and sistema = 200
           and agencia = @F_agencia
           and indicador='A'
        set @F_comprobante_aux = @F_comprobante
       	set @F_Total_Comp = @F_Total_Comp + 1
     	end

  	if @F_nro_cuenta = 0 
      select @F_nro_cuenta = cast(@F_comprobante_via as varchar),
             @F_comprobante_via = 0
            
  	update @tb_temporal_cursor 
    		set contestado = @F_contestado
   		   , nro_cuenta = @F_nro_cuenta
   					, comprobante_via =  @F_comprobante_via
   					, moneda   =  @F_moneda
  		where id = @F_count

		  set	@F_count = @F_count +1

    insert into #tabla_reporte   
    select 2,2,1,Linea_texto = cast(isnull(@F_nombcorto,'') as char(10))+space(2)+
                               replace(str(isnull(@F_comprobante,0),15),' ',0 )+space(4)+ 
                               str(isnull (@F_cliente,0),15)+space(2)+
                               str(isnull (@f_ci_nit, 0),15)+space(2)+
                               str(isnull(@F_cod_tran,0),4)+space(4)+
                               isnull(cast((select a1.sigla from pam_codtran as a1 WITH (NOLOCK)
                                      where a1.cod_tran = @F_cod_tran and a1.sistema =200 and a1.indicador ='A') as char(15)),'') +space(3)+
                               replace(str(isnull(@F_nro_cuenta,0),15),'       ','')+space(1)+
                               dbo.Fn_Monto_Dinero_GLB(isnull(@F_importe_ope,0))+space(3)+
                               isnull(@F_moneda,'$') + space(7) + 
                               case when @F_contestado = 0 then 'NO' when @F_contestado = 2 then 'NA'
                               else 'SI' END+SPACE(8) + LTRIM(@F_indicador) 

   if @F_comprobante <> @F_comprobante_aux 
      insert into #tabla_reporte   
      select 2,2,1,Linea_texto  = ''
	end
	
 insert into #tabla_reporte     
 select 2,2,1,Linea_Texto =''
 union all 
 select 2,2,1,Linea_Texto = space(10)+'TOTAL OPERACIONES ===> '+str(@F_Total_Comp,5)           
 
 set @RowCount=0
 select @RowCount=count(id) from #tabla_reporte where tipo =2 and subtipo=2     
         
 if @RowCount = 8 --Cantidad de lineas que ocupa el header(6) y footer(2)
    update #tabla_reporte set  visible=0 where tipo =2 and subtipo=2        
      
------------------------------------------------------------------------------------------------------------------
-- *** MOVIMIENTO DE BLOQUEO DESBLOQUEO CAJA DE AHORRO RD-2356
------------------------------------------------------------------------------------------------------------------

   --2,3,1- 
   insert into #tabla_reporte    
   Select 2,3,1,Linea_texto = ''    
   union all Select 2,3,1,Linea_texto = '-----------------------------------------------------------------' 
   union all Select 2,3,1,Linea_texto = '###  BLOQUEO DE CAJA DE AHORRO / RETENCIÓN DE CAJA DE AHORRO  ###'
   union all Select 2,3,1,Linea_texto = '-----------------------------------------------------------------' 
   union all Select 2,3,1,Linea_texto = '-----------------------------------------------------------------------------------------------------' 
   union all Select 2,3,1,Linea_texto = 'USUARIO         NRO_CTA CLIENTE                             OPERACIÓN                    MONTO MONEDA'
   union all Select 2,3,1,Linea_texto = '-----------------------------------------------------------------------------------------------------'
  -- if @I_Indicador <>''
  --    set @F_cadindicador = +'a.indicador§'+@I_Indicador+'¶'
  -- else
      set @F_cadindicador = ''
    
       set @F_Condicion_doc = 'a.agencia§'  +case @I_agencia when 0 then '' 
                                            else ltrim(str(@I_agencia))end+'¶'
                             +'a.usuario§'  +case @I_Usuario when 0 then '' 
                                            else ltrim(str(@I_Usuario))end+'¶'  
                             +@F_cadindicador                                                                                         
    exec @F_error_exec=Construct_GLB
                       @I_mostrar    = 'N',
                       @IO_construct = @F_Condicion_doc  output,
                       @O_error_msg  = @O_error_msg output
    IF @@error <> 0 
       BEGIN
       SET @O_error_msg ='Error al ejecutar Construct_GLB.'+@O_error_msg
       GOTO Error
       END    
				IF @F_error_exec <> 0 GOTO Error      
    
insert into #temp_tabla_reporte
select 
    f.nombcorto
		, a.nro_cuenta
		, d.nombre_ful
		, b.sigla
		, a.monto
		, g.sigla
		, f.agencia
		, a.sec
		, a.bloqueo
		, f.usuario

  from  cahmst_bloqueo a 
  inner join pamcah_tipo_bloqueo b on a.tipo_bloqueo = b.tipo_bloqueo
		and a.fecha_proceso = @I_fecha_proceso
		and a.indicador in ('A','R')
		and b.indicador = 'A'
		and b.sistema = 200 
		and a.sistema   = 200
		inner join climst_clioper c on a.nro_cuenta = c.nro_cuenta
		and c.fecha_proceso_hasta = '01-01-2050'
		and c.sistema = 200
		and c.sec = 1 
		and c.tipo_rel = 4
		inner join climst_cliente d on c.cliente = d.cliente
		and d.indicador = 'A'
		and d.fecha_proceso_hasta = '01-01-2050'
		inner join cahmst_maestro e on c.nro_cuenta = e.nro_cuenta
		inner join climov_usuario f on a.usuario = f.cliente
		and f.indicador = 'A' 
		and @z_fecha_proceso between f.fecha_proceso and f.fecha_proceso_hasta
		inner join pam_moneda g on e.moneda = g.moneda
		and g.indicador = 'A'
		
      
    insert into #tabla_reporte    
    exec('select 2,3,1,LINEA_TEXTO = cast(a.nombcorto as char(10)) + space(1)+  '+
              '  str(a.nro_cuenta,12) + space(1)+ '+ 
              '  cast(a.nombre_ful as char(35)) + space(1)+ '+ 
              '  cast(a.siglab as char(20)) + space(1)+ '+
              '  str(a.monto,13,2) + space(1)+ '+
              '  a.sigla '+
          ' from #temp_tabla_reporte as a'+ 
         ' where ' +  @F_Condicion_doc +
           ' and a.bloqueo = 1 '+
           ' order by a.nro_cuenta,a.sec' ) 
   insert into #tabla_reporte         
   EXEC(' select 2,3,1,linea_texto = ''TOTAL OPER --> '' + str(isnull(COUNT (a.nro_cuenta),0),10)'+
          ' from #temp_tabla_reporte as a'+ 
         ' where ' +  @F_Condicion_doc +
           ' and a.bloqueo = 1 ')
           
      set @RowCount=0
      select @RowCount=count(id) from #tabla_reporte where tipo =2 and subtipo=3       
      if @RowCount = 8 --Cantidad de lineas que ocupa el header(7) y footer(1)
      begin 
            update #tabla_reporte set  visible=0 where tipo =2 and subtipo=3        
      end
      
 
   --2,4,1- 
   insert into #tabla_reporte    
   Select 2,4,1,Linea_texto = ''    
   union all Select 2,4,1,Linea_texto = '---------------------------------------------------------------' 
   union all Select 2,4,1,Linea_texto = '###  DESBLOQUEO CAJA DE AHORRO / LIBERACIÓN CAJA DE AHORRO  ###'
   union all Select 2,4,1,Linea_texto = '---------------------------------------------------------------' 
   union all Select 2,4,1,Linea_texto = '-----------------------------------------------------------------------------------------------------' 
   union all Select 2,4,1,Linea_texto = 'USUARIO         NRO_CTA CLIENTE                             OPERACIÓN                    MONTO MONEDA'
   union all Select 2,4,1,Linea_texto = '-----------------------------------------------------------------------------------------------------'
  --if @I_Indicador <>''
   --   set @F_cadindicador = +'a.indicador§'+@I_Indicador+'¶'
   --else
      set @F_cadindicador = ''
    
       set @F_Condicion_doc = 'a.agencia§'  +case @I_agencia when 0 then '' 
                                            else ltrim(str(@I_agencia))end+'¶'
                             +'a.usuario§'  +case @I_Usuario when 0 then '' 
                                            else ltrim(str(@I_Usuario))end+'¶'  
                             +@F_cadindicador                                                                                         
    exec @F_error_exec=Construct_GLB
                       @I_mostrar    = 'N',
                       @IO_construct = @F_Condicion_doc  output,
                       @O_error_msg  = @O_error_msg output
    IF @@error <> 0 
       BEGIN
       SET @O_error_msg ='Error al ejecutar Construct_GLB.'+@O_error_msg
       GOTO Error
       END    
				IF @F_error_exec <> 0 GOTO Error      
       
    insert into #tabla_reporte   
    exec('select 2,4,1,LINEA_TEXTO = cast(a.nombcorto as char(10)) + space(1)+  '+
              '  str(a.nro_cuenta,12) + space(1)+ '+ 
              '  cast(a.nombre_ful as char(35)) + space(1)+ '+ 
              '  cast(a.siglab as char(20)) + space(1)+ '+
              '  str(isnull(a.monto,0),13,2) + space(1)+ '+
              '  a.sigla '+
          ' from #temp_tabla_reporte as a'+ 
         ' where ' +  @F_Condicion_doc +
           ' and a.bloqueo = 0 '+
           ' order by a.nro_cuenta,a.sec' ) 
           
   insert into #tabla_reporte          
   EXEC(' select 2,4,1,linea_texto = ''TOTAL OPER --> '' + str(isnull(COUNT (a.nro_cuenta),0),10)'+
        ' from #temp_tabla_reporte as a'+ 
         ' where ' +  @F_Condicion_doc +
           ' and a.bloqueo = 0 ')
           
      set @RowCount=0
      select @RowCount=count(id) from #tabla_reporte where tipo =2 and subtipo=4       
      if @RowCount = 8 --Cantidad de lineas que ocupa el header(7) y footer(1)
      begin 
            update #tabla_reporte set  visible=0 where tipo =2 and subtipo=4        
      end    
------------------------------------------------------------------------------------------------------------------
-- *** FIN MOVIMIENTO DE BLOQUEO DESBLOQUEO CAJA DE AHORRO
------------------------------------------------------------------------------------------------------------------
-- endregion
-- region cct
------------------------------------------------------------------------------------------------------------------
----APERTURA DE CUENTA CORRIENTE
------------------------------------------------------------------------------------------------------------------   
    insert into #tabla_reporte
    Select 3,1,1,Linea_texto = ''
    union all Select 3,1,1,Linea_texto = ''
    union all Select 3,1,1,Linea_texto = '-------------------------------------------------' 
    union all Select 3,1,1,Linea_texto = '###  LISTADO DE APERTURA DE CUENTA CORRIENTE  ###'
    union all Select 3,1,1,Linea_texto = '-------------------------------------------------' 
    set @F_Criterio1 = 'c.cliente§' +case @I_Usuario when 0 then '' 
                                     else ltrim(str(@I_Usuario))end+'¶'
                      +'c.agencia§'+ case @I_agencia when 0 then '' 
                                     else ltrim(str(@I_agencia))end+'¶'
    exec @F_error_exec=Construct_GLB
                       @I_mostrar    = 'N',
                       @IO_construct = @F_criterio1  output,
                       @O_error_msg  = @O_error_msg output
    IF @@error <> 0 
       BEGIN
       SET @O_error_msg ='Error al ejecutar Construct_GLB.'
       GOTO Error
       END  
				IF @F_error_exec <> 0 GOTO Error    
       
    delete from @tablaTemp  
    insert into @tablaTemp   
    exec rep_apertura_diaria_cuenta_corriente
                                    @I_fecha_desde  = @z_fecha_proceso,
                                    @I_fecha_hasta  = @z_fecha_proceso,
                                    @P_condicion    = @F_Criterio1,
                                    @I_tipo         = 0 
    
    if @@ROWCOUNT = 5 --Retorna solo titulos
      begin 
            update #tabla_reporte set  visible=0 where tipo =3 and subtipo=1        
      end   
    else
        begin
              insert into #tabla_reporte                                    
              Select 3,1,1,linea from @tablaTemp                                     
        end 
----------------------------------------------------------------------------------------------------
----  MOVIMIENTOS DE CUENTA CORRIENTE
-----------------------------------------------------------------------------------------------------     
    if @I_Indicador<> ''
       set @F_cadindicador = 'a.indicador§'+@I_Indicador+'¶'
    else
       set @F_cadindicador = ''        
    set @F_Criterio = 'b.cliente§' +case @I_Usuario when 0 then '' 
                                   else ltrim(str(@I_Usuario))end+'¶'
                     +'b.agencia§'+ case @I_agencia when 0 then '' 
                                      else ltrim(str(@I_agencia))end+'¶'
                     +@F_cadindicador -- 'a.indicador§'+@I_Indicador+'¶'                                                  
    exec @F_error_exec=Construct_GLB
                       @I_mostrar    = 'N',
                       @IO_construct = @F_criterio  output,
                       @O_error_msg  = @O_error_msg output
    IF @@error <> 0 
       BEGIN
       SET @O_error_msg ='Error al ejecutar Construct_GLB.'
       GOTO Error
       END       
				IF @F_error_exec <> 0 GOTO Error         
       
   insert into #tabla_reporte 
   Select 3,2,1,Linea_texto = ''
   union all Select 3,2,1,Linea_texto = '-----------------------------------------' 
   union all Select 3,2,1,Linea_texto = '###  MOVIMIENTOS DE CUENTA CORRIENTE  ###'
   union all Select 3,2,1,Linea_texto = '-----------------------------------------' 
   union all Select 3,2,1,Linea_texto = '--------------------------------------------------------------------------------------------------------------------------------------------------' 
   union all Select 3,2,1,Linea_texto = 'USUARIO     COMPROBANTE         CLIENTE   CI/NIT  COD    TRANSACCIÓN         CUENTA                  MONTO    MONEDA  PROC.CAJA   ESTADO   ' 
   union all Select 3,2,1,Linea_texto = '--------------------------------------------------------------------------------------------------------------------------------------------------' 
   
   delete from  @tb_temporal_cursor
  	insert into @tb_temporal_cursor
   EXEC(' select a.comprobante, a.sec, a.nro_cuenta,  0 as saldo,'+
               ' a.cod_tran, a.agencia, a.sistema_via, a.comprobante_via,'+ 
               ' a.importe_ope, a.moneda_via, a.importe_via, a.usuario,'+
               ' a.indicador, nit = isnull(nit,''0''),''0'','''','''','''',''0'',''0'',''0'''+
          ' from ccttrn_trans  as a WITH (NOLOCK) '+
          'inner join climov_usuario as b WITH (NOLOCK)'+
            ' on a.usuario = b.cliente '+
            'and a.fecha_proceso between b.fecha_proceso and b.fecha_proceso_hasta '+
            'and b.indicador= ''A'''+  
          ' left outer join climst_clioper as c WITH (NOLOCK)'+
            ' on c.nro_cuenta = a.nro_cuenta '+
           ' and c.sistema = 100 '+
           ' and c.sec = 1 '+
           ' and c.fecha_proceso_hasta = ''01/01/2050'' '+
          ' left outer join climst_cliente as d WITH (NOLOCK) '+
           '  on d.cliente = c.cliente '+
           ' and d.fecha_proceso_hasta = ''01/01/2050'''+
           ' and d.indicador = ''A'''+
         ' where a.fecha_proceso= '+ @F_fecha +
           ' and '+ @F_Criterio +
           ' and exists(select y.cod_rel '+
                        ' from pam_tablas y '+
                        'where y.tabla= 267 '+
                         ' and y.cod_rel = a.cod_tran '+
                         ' and y.indicador = ''A'' '+
                         ' and y.fecha_proceso_hasta = ''01-01-2050'') '+         
           ' and a.comprobante in (select x.comprobante '+
                                   ' from ccttrn_trans as x WITH (NOLOCK)'+
                                  ' where x.fecha_proceso= ' + @F_fecha +
                                   '  and x.indicador=''A'''+
                                   '  and exists(select y.cod_rel'+
                                                 ' from pam_tablas y '+
                                                ' where y.tabla= 267 '+
                                                  ' and y.cod_rel = x.cod_tran '+
                                                  ' and y.indicador = ''A'''+
                                                  ' and y.fecha_proceso_hasta = ''01-01-2050'') '+                                                                                               
           ' and x.sistema_via in (100,200,300,601,30))')
 
    update t 
       set t.nombre_corto = u.nombcorto
      from @tb_temporal_cursor t 
     inner join climst_usuario u on t.usuario = u.cliente
       and u.indicador='A'

   	update t 
       set t.descripcion = p.descripcion
   	  from @tb_temporal_cursor t 
   	 inner join pam_codtran p on t.cod_tran = p.cod_tran
   	   and p.sistema=100
   	   and p.indicador='A'
       
    select @F_maxsec =max(id), @F_count=min(id) from @tb_temporal_cursor
   	select @F_count =isnull(@F_count,1),
           @F_maxsec =isnull(@F_maxsec,0),
   	       @F_Total_Comp=0,
           @F_comprobante_aux = 0
   	while (@F_count <= @F_maxsec)
   	begin
     	select @F_comprobante = t.comprobante
          	, @F_agencia=t.agencia 
          	, @F_nro_cuenta =  t.nro_cuenta
          	, @F_comprobante_via = t.comprobante_via
          	, @F_nombcorto = t.nombre_corto
          	, @F_moneda2 = t.moneda_via
          	, @f_ci_nit = t.nit
          	, @F_cod_tran = t.cod_tran
          	, @F_importe_ope = importe_ope
          	, @F_indicador = indicador
          	, @F_comprobante_aux = t.comprobante_aux
       	from @tb_temporal_cursor t
       where t.id = @F_count

   	  select @F_moneda = isnull(sigla,'') 
   				 from pam_moneda WITH (NOLOCK)
       where moneda = @F_moneda2 
         and indicador='A'
         
      select @F_cliente = cliente --si
        from climst_clioper WITH (NOLOCK)
       where nro_cuenta=@F_nro_cuenta 
         and sec=1 
         and fecha_proceso_hasta='01-01-2050'
         and sistema = 100

     	if @F_comprobante <> @F_comprobante_aux
        	begin
          	set @F_contestado = 2
          	select @F_contestado = isnull(b.contestado,0)
            	from cajtrn_puente b
            where b.comprobante = @F_comprobante
              and sistema = 100
              and agencia = @F_agencia
              and indicador='A'
           set @F_comprobante_aux = @F_comprobante
          	set @F_Total_Comp = @F_Total_Comp + 1
        	end

     	if @F_nro_cuenta = 0 
         select @F_nro_cuenta = cast(@F_comprobante_via as varchar),
                @F_comprobante_via = 0
               
     	update @tb_temporal_cursor 
       		set contestado = @F_contestado
      		   , nro_cuenta = @F_nro_cuenta
      					, comprobante_via =  @F_comprobante_via
      					, moneda   =  @F_moneda
     		where id = @F_count

   		  set	@F_count = @F_count +1

       insert into #tabla_reporte   
       select 3,2,1,Linea_texto = cast(isnull(@F_nombcorto,'') as char(10))+space(2)+
                                  replace(str(isnull(@F_comprobante,0),15),' ',0 )+space(4)+ 
                                  str(isnull (@F_cliente,0),15)+space(2)+
                                  str(isnull (@f_ci_nit, 0),15)+space(2)+
                                  str(isnull(@F_cod_tran,0),4)+space(4)+
                                  isnull(cast((select a1.sigla from pam_codtran as a1 WITH (NOLOCK)
                                                where a1.cod_tran = @F_cod_tran and a1.sistema =100 and a1.indicador ='A') as char(15)),'') +space(3)+
                                  replace(str(isnull(@F_nro_cuenta,0),15),'       ','')+space(1)+
                                  dbo.Fn_Monto_Dinero_GLB(isnull(@F_importe_ope,0))+space(3)+
                                  isnull(@F_moneda,'$') + space(7) + 
                                  case when @F_contestado = 0 then 'NO' when @F_contestado = 2 then 'NA'
                                  else 'SI' END+SPACE(8) + LTRIM(@F_indicador) 

      if @F_comprobante <> @F_comprobante_aux 
         insert into #tabla_reporte   
         select 3,2,1,Linea_texto  = ''
   	end

    insert into #tabla_reporte     
    select 3,2,1,linea_Texto =''          
    union all 
    select 3,2,1,linea_texto = space(10)+'TOTAL OPERACIONES ===> '+str(@F_Total_Comp,5)           
    set @RowCount=0
    select @RowCount=count(id) from #tabla_reporte where tipo =3 and subtipo=2       
    if @RowCount =9 --Cantidad de lineas que ocupa el header(5) y footer(2)
       update #tabla_reporte set  visible=0 where tipo =3 and subtipo=2        
-- endregion  
-- region solicitud_chequeras

---------------------------------------------------------------------------------------------------
------- SOLICITUD DE CHEQUERAS
---------------------------------------------------------------------------------------------------

   insert into #tabla_reporte 
   Select 3,3,1,Linea_texto = ''   
   union all Select 3,3,1,Linea_texto = '------------------------------------------' 
   union all Select 3,3,1,Linea_texto = '###  LISTADO DE SOLICITUD DE CHEQUERA  ###'
   union all Select 3,3,1,Linea_texto = '------------------------------------------' 
   union all Select 3,3,1,Linea_texto = '----------------------------------------------------------------------------------------------------------------------------------' 
   union all Select 3,3,1,Linea_texto = 'USUARIO     NRO_CUENTA    NRO SOLIC  PERSONA QUE RECOGE         DOCUMENTO                  ESTADO CHEQUERA ' 
   union all Select 3,3,1,Linea_texto = '----------------------------------------------------------------------------------------------------------------------------------' 
       
    set @F_Criterio1 = 'a.usr_digitada§' +case @I_Usuario when 0 then '' 
                                     else ltrim(str(@I_Usuario))end+'¶'
                      +'a.agencia_digitada§'+ case @I_agencia when 0 then ltrim(str(@F_agencia_us)) --'' 
                                     else ltrim(str(@I_agencia))end+'¶'
    exec @F_error_exec=Construct_GLB
                       @I_mostrar    = 'N',
                       @IO_construct = @F_criterio1  output,
                       @O_error_msg  = @O_error_msg output
    IF @@error <> 0 
       BEGIN
       SET @O_error_msg ='Error al ejecutar Construct_GLB.'
       GOTO Error
       END  
				IF @F_error_exec <> 0 GOTO Error     

		INSERT INTO #temp_tabla_custodio
       exec ('SELECT c.nombcorto 
                   , a.nro_cuenta
                   , a.nro_solicitud
                   , a.cliente_entrega
                   , a.documento_entrega
                   , d.sigla
                   , c.fecha_proceso
                   , c.fecha_proceso_hasta
                   , a.usr_digitada
                   , a.agencia_digitada
                   , a.fecha_digitada
                   , a.agencia_entrega
                   , a.usr_en_custodio
                   , a.fecha_en_custodio
                   , a. usr_entrega_cliente
                   , a.fecha_entrega_cliente
                FROM cctmst_chequera a 
               INNER JOIN cctmst_maestro b	ON a.nro_cuenta = b.nro_cuenta
          					AND b.estado = 1
          					INNER JOIN climov_usuario c ON a.usr_digitada = c.cliente 
          					AND c.indicador = ''A''
          					INNER JOIN pam_tablas d ON d.codigo = a.estado
          					AND d.tabla = 17 
          					AND d.indicador = ''A''
          					AND d.fecha_proceso_hasta = ''01-01-2050'' 
          					and a.fecha_digitada between c.fecha_proceso and c.fecha_proceso_hasta '+
       				' where '+ @F_criterio1+'
               and a.fecha_digitada = '+ @F_fecha )
 
   insert into #tabla_reporte     
   EXEC(' select 3,3,1,linea_texto = cast(isnull(a.nombcorto,'''') as char(8)) + space(2)+ ' + 
               ' str(isnull(a.nro_cuenta,0),10) +space(2)+ '+ 
               ' str(isnull(a.nro_solicitud,0),10)  +space(5)+ '+ 
               ' cast(isnull(a.cliente_entrega,'''') as char(25)) +space(2)+ '+ 
               ' cast(isnull(a.documento_entrega,'''') as char(25)) +space(2)+ '+ 
               ' cast(isnull(a.sigla,'''') as char(10)) ' +
         ' from #temp_tabla_custodio a '+
         'group by a.nombcorto, a.nro_cuenta , a.nro_solicitud,a.cliente_entrega,a.documento_entrega,a.sigla ')

   insert into #tabla_reporte    
   EXEC(' select 3,3,1,linea_texto = ''Total Oper  --> '' + str(isnull(count(distinct(a.nro_solicitud)),0),10) '+
          ' from #temp_tabla_custodio as a ')
        
   
      set @RowCount=0
      select @RowCount=count(id) from #tabla_reporte where tipo =3 and subtipo=3       
      if @RowCount = 8 --Cantidad de lineas que ocupa el header(6) y footer(2)
      begin 
            update #tabla_reporte set  visible=0 where tipo =3 and subtipo=3        
      end      
---------------------------------------------------------------------------------------------------
-------LISTADO DE CHEQUERAS EN CUSTODIO 
---------------------------------------------------------------------------------------------------
   insert into #tabla_reporte 
   Select 3,4,1,Linea_texto = ''   
   union all Select 3,4,1,Linea_texto = '------------------------------------------' 
   union all Select 3,4,1,Linea_texto = '###  LISTADO DE CHEQUERAS EN CUSTODIO  ###'
   union all Select 3,4,1,Linea_texto = '------------------------------------------' 
   union all Select 3,4,1,Linea_texto = '----------------------------------------------------------------------------------------------------------------------------------' 
   union all Select 3,4,1,Linea_texto = 'USUARIO     NRO_CUENTA    NRO SOLIC  PERSONA QUE RECOGE         DOCUMENTO                  ESTADO CHEQUERA ' 
   union all Select 3,4,1,Linea_texto = '----------------------------------------------------------------------------------------------------------------------------------' 
       
    set @F_Criterio1 = 'a.usr_en_custodio§' +case @I_Usuario when 0 then '' 
                                     else ltrim(str(@I_Usuario))end+'¶'
                      +'a.agencia_entrega§'+ case @I_agencia when 0 then  ltrim(str(@F_agencia_us)) --'' 
                                     else ltrim(str(@I_agencia))end+'¶'
    exec @F_error_exec=Construct_GLB
                       @I_mostrar    = 'N',
                       @IO_construct = @F_criterio1  output,
                       @O_error_msg  = @O_error_msg output
    IF @@error <> 0 
       BEGIN
       SET @O_error_msg ='Error al ejecutar Construct_GLB.'
       GOTO Error
       END  
				IF @F_error_exec <> 0 GOTO Error   
				 
   DELETE from #temp_tabla_custodio
 		INSERT INTO #temp_tabla_custodio
			  				exec ('SELECT c.nombcorto 
              , a.nro_cuenta
              , a.nro_solicitud
              , a.cliente_entrega
              , a.documento_entrega
              , d.sigla
              , c.fecha_proceso
              , c.fecha_proceso_hasta
              , a.usr_digitada
              , a.agencia_digitada
              , a.fecha_digitada
              , a.agencia_entrega
              , a.usr_en_custodio
              , a.fecha_en_custodio
              , a. usr_entrega_cliente
              , a.fecha_entrega_cliente
           FROM cctmst_chequera a 
             INNER JOIN cctmst_maestro b	ON a.nro_cuenta = b.nro_cuenta
        					AND b.estado = 1
        					INNER JOIN climov_usuario c ON a.usr_en_custodio = c.cliente 
        					AND c.indicador = ''A''
        					INNER JOIN pam_tablas d ON d.codigo = a.estado
        					AND d.tabla = 17 
        					AND d.indicador = ''A''
        					AND d.fecha_proceso_hasta = ''01-01-2050'' 
        					and a.fecha_en_custodio between c.fecha_proceso and c.fecha_proceso_hasta '+
     					' where '+ @F_criterio1+'
              and a.fecha_en_custodio = '+ @F_fecha )
              
   insert into #tabla_reporte 
   EXEC(' select 3,4,1,linea_texto = cast(isnull(a.nombcorto,'''') as char(8)) + space(2)+ ' + 
               ' str(isnull(a.nro_cuenta,0),10) +space(2)+ '+ 
               ' str(isnull(a.nro_solicitud,0),10)  +space(5)+ '+ 
               ' cast(isnull(a.cliente_entrega,'''') as char(25)) +space(2)+ '+ 
               ' cast(isnull(a.documento_entrega,'''') as char(25)) +space(2)+ '+ 
               ' cast(isnull(a.sigla,'''') as char(10)) ' +
          ' from #temp_tabla_custodio a '+
          'group by a.nombcorto, a.nro_cuenta , a.nro_solicitud,a.cliente_entrega,a.documento_entrega,a.sigla ')         

   insert into #tabla_reporte 
   EXEC(' select 3,4,1,linea_texto = ''TOTAL OPER --> '' + str(isnull(COUNT (distinct(a.nro_solicitud)),0),10)'+
          ' from #temp_tabla_custodio a')     
       
      set @RowCount=0
      select @RowCount=count(id) from #tabla_reporte where tipo =3 and subtipo=4       
      if @RowCount = 8 --Cantidad de lineas que ocupa el header(6) y footer(2)
      begin 
            update #tabla_reporte set  visible=0 where tipo =3 and subtipo=4       
      end    
          
---------------------------------------------------------------------------------------------------
-------LISTADO DE CHEQUERAS ENTREGADAS
---------------------------------------------------------------------------------------------------

   insert into #tabla_reporte 
   Select 3,5,1,Linea_texto = ''   
   union all Select 3,5,1,Linea_texto = '----------------------------------------------------' 
   union all Select 3,5,1,Linea_texto = '###  LISTADO DE CHEQUERAS ENTREGADAS AL CLIENTE  ###'
   union all Select 3,5,1,Linea_texto = '----------------------------------------------------' 
   union all Select 3,5,1,Linea_texto = '----------------------------------------------------------------------------------------------------------------------------------' 
   union all Select 3,5,1,Linea_texto = 'USUARIO     NRO_CUENTA    NRO SOLIC  PERSONA QUE RECOGE         DOCUMENTO                  ESTADO CHEQUERA ' 
   union all Select 3,5,1,Linea_texto = '----------------------------------------------------------------------------------------------------------------------------------' 
       
    set @F_Criterio1 = 'a.usr_entrega_cliente§' +case @I_Usuario when 0 then '' 
                                     else ltrim(str(@I_Usuario))end+'¶'
                      +'a.agencia_entrega§'+ case @I_agencia when 0 then ltrim(str(@F_agencia_us))--'' 
                                     else ltrim(str(@I_agencia))end+'¶'
    exec @F_error_exec=Construct_GLB
                       @I_mostrar    = 'N',
                       @IO_construct = @F_criterio1  output,
                       @O_error_msg  = @O_error_msg output
    IF @@error <> 0 
       BEGIN
       SET @O_error_msg ='Error al ejecutar Construct_GLB.'
       GOTO Error
       END  
				IF @F_error_exec <> 0 GOTO Error    
   
		  DELETE from #temp_tabla_custodio
		  INSERT INTO #temp_tabla_custodio
							exec ('SELECT c.nombcorto 
                   , a.nro_cuenta
                   , a.nro_solicitud
                   , a.cliente_entrega
                   , a.documento_entrega
                   , d.sigla
                   , c.fecha_proceso
                   , c.fecha_proceso_hasta
                   , a.usr_digitada
                   , a.agencia_digitada
                   , a.fecha_digitada
                   , a.agencia_entrega
                   , a.usr_en_custodio
                   , a.fecha_en_custodio
                   , a. usr_entrega_cliente
                   , a.fecha_entrega_cliente
              FROM cctmst_chequera a 
                   INNER JOIN cctmst_maestro b	ON a.nro_cuenta = b.nro_cuenta
              					AND b.estado = 1
              					INNER JOIN climov_usuario c ON a.usr_entrega_cliente = c.cliente 
              					AND c.indicador = ''A''
              					INNER JOIN pam_tablas d ON d.codigo = a.estado
              					AND d.tabla = 17 
              					AND d.indicador = ''A''
              					AND d.fecha_proceso_hasta = ''01-01-2050'' 
              					and a.fecha_entrega_cliente between c.fecha_proceso and c.fecha_proceso_hasta '+
        					' where '+ @F_criterio1+'
               and a.fecha_entrega_cliente = '+ @F_fecha )

   insert into #tabla_reporte     
   EXEC(' select 3,5,1,linea_texto = cast(isnull(a.nombcorto,'''') as char(8)) + space(2)+ ' + 
                 ' str(isnull(a.nro_cuenta,0),10) +space(2)+ '+ 
                 ' str(isnull(a.nro_solicitud,0),10)  +space(5)+ '+ 
                 ' cast(isnull(a.cliente_entrega,'''') as char(25)) +space(2)+ '+ 
                 ' cast(isnull(a.documento_entrega,'''') as char(25)) +space(2)+ '+ 
                 ' cast(isnull(a.sigla,'''') as char(10)) ' +
          ' from #temp_tabla_custodio a '+
           'group by a.nombcorto, a.nro_cuenta , a.nro_solicitud,a.cliente_entrega,a.documento_entrega,a.sigla')     

   insert into #tabla_reporte 
   EXEC(' select 3,5,1,linea_texto = ''TOTAL OPER  -->'' + str(isnull(COUNT(distinct(a.nro_solicitud)),0),10)' +              
          ' from #temp_tabla_custodio a')     

      set @RowCount=0
      select @RowCount=count(id) from #tabla_reporte where tipo =3 and subtipo=5       
      if @RowCount = 8 --Cantidad de lineas que ocupa el header(6) y footer(2)
      begin 
            update #tabla_reporte set  visible=0 where tipo =3 and subtipo=5       
      end    

------------------------------------------------------------------------------------------------------------------
-- *** MOVIMIENTO DE BLOQUEO DESBLOQUEO CUENTA CORRIENTE RD-5524
------------------------------------------------------------------------------------------------------------------
   --3,6,1- 
   insert into #tabla_reporte    
   Select 3,6,1,Linea_texto = ''    
   union all Select 3,6,1,Linea_texto = '-----------------------------------------------------------------' 
   union all Select 3,6,1,Linea_texto = '###  BLOQUEO DE CUENTA CORRIENTE / RETENCIÓN DE CUENTA CORRIENTE  ###'
   union all Select 3,6,1,Linea_texto = '-----------------------------------------------------------------' 
   union all Select 3,6,1,Linea_texto = '-----------------------------------------------------------------------------------------------------' 
   union all Select 3,6,1,Linea_texto = 'USUARIO         NRO_CTA CLIENTE                             OPERACIÓN                    MONTO MONEDA'
   union all Select 3,6,1,Linea_texto = '-----------------------------------------------------------------------------------------------------'

   if @I_Indicador <>''
      set @F_cadindicador = +'a.indicador§'+@I_Indicador+'¶'
   else
      set @F_cadindicador = ''
    
      set @F_Condicion_doc = 'f.agencia§'  +case @I_agencia when 0 then '' 
                                            else ltrim(str(@I_agencia))end+'¶'
                             +'a.usuario§'  +case @I_Usuario when 0 then '' 
                                            else ltrim(str(@I_Usuario))end+'¶'  
                             +@F_cadindicador                                                                                         
    exec @F_error_exec=Construct_GLB
                       @I_mostrar    = 'N',
                       @IO_construct = @F_Condicion_doc  output,
                       @O_error_msg  = @O_error_msg output
				IF @@error <> 0 
							BEGIN
									SET @O_error_msg ='Error al ejecutar Construct_GLB.'
									GOTO Error
							END   
				IF @F_error_exec <> 0 GOTO Error    
    
				INSERT INTO #temp_bloqueo_cct
					exec(	'SELECT f.nombcorto
        									, a.nro_cuenta
        									, d.nombre_ful
        									, b.sigla
        									, a.monto 
        									, g.sigla
        									, f.agencia
        									, a.usuario
        									, a.fecha_proceso
        									, a.bloqueo
        									, a.indicador
      								FROM cahmst_bloqueo a 
      								     INNER JOIN pamcah_tipo_bloqueo b ON a.tipo_bloqueo = b.tipo_bloqueo
      													and a.indicador in (''A'',''R'')
      													and a.sistema   = 100 
      													and a.fecha_proceso = '+@F_fecha+
      													'and b.indicador = ''A''
      													INNER JOIN climst_clioper c ON a.nro_cuenta = c.nro_cuenta
      													and c.fecha_proceso_hasta = ''01-01-2050''
      													and c.sistema   = 100 
      													and c.sec       = 1
      													and c.tipo_rel  = 4
      													INNER JOIN climst_cliente d ON c.cliente   = d.cliente
      													and d.indicador = ''A''
      													and d.fecha_proceso_hasta = ''01-01-2050''
      													INNER JOIN cctmst_maestro e ON c.nro_cuenta = e.nro_cuenta
      													INNER JOIN climov_usuario f ON a.usuario   = f.cliente
      													and f.indicador = ''A''
      													and '+@F_fecha+' between f.fecha_proceso and f.fecha_proceso_hasta
      													INNER JOIN pam_moneda g ON e.moneda    = g.moneda 
      													and g.indicador = ''A''
													WHERE ' +  @F_Condicion_doc +
												'order by a.nro_cuenta,a.sec')
				   
    insert into #tabla_reporte    
    select 3,6,1,LINEA_TEXTO = 
				            cast(a.nombcorto as char(10)) + space(1)+
                str(a.nro_cuenta,12) + space(1)+
                cast(a.nombre_ful as char(35)) + space(1)+
                cast(a.siglab as char(20)) + space(1)+
                str(a.monto,13,2) + space(1)+
                a.sigla 
      from  #temp_bloqueo_cct   as a 
     where a.bloqueo = 1 
           
   insert into #tabla_reporte         
   select 3,6,1,linea_texto = 'TOTAL OPER --> ' + str(isnull(COUNT (a.nro_cuenta),0),10)
     from #temp_bloqueo_cct as a 
    where a.bloqueo = 1 
           
      set @RowCount=0
      select @RowCount=count(id) from #tabla_reporte where tipo =3 and subtipo=6       
      if @RowCount = 8 --Cantidad de lineas que ocupa el header(7) y footer(1)
      begin 
            update #tabla_reporte set  visible=0 where tipo =3 and subtipo=6        
      end
      
      
   --3,7,1- 
   insert into #tabla_reporte    
   Select 3,7,1,Linea_texto = ''    
   union all Select 3,7,1,Linea_texto = '---------------------------------------------------------------' 
   union all Select 3,7,1,Linea_texto = '###  DESBLOQUEO CUENTA CORRIENTE / LIBERACIÓN CUENTA CORRIENTE  ###'
   union all Select 3,7,1,Linea_texto = '---------------------------------------------------------------' 
   union all Select 3,7,1,Linea_texto = '-----------------------------------------------------------------------------------------------------' 
   union all Select 3,7,1,Linea_texto = 'USUARIO         NRO_CTA CLIENTE                             OPERACIÓN                    MONTO MONEDA'
   union all Select 3,7,1,Linea_texto = '-----------------------------------------------------------------------------------------------------'
   if @I_Indicador <>''
      set @F_cadindicador = +'a.indicador§'+@I_Indicador+'¶'
   else
      set @F_cadindicador = ''
    
       set @F_Condicion_doc = 'f.agencia§'  +case @I_agencia when 0 then '' 
                                            else ltrim(str(@I_agencia))end+'¶'
                             +'a.usuario§'  +case @I_Usuario when 0 then '' 
                                            else ltrim(str(@I_Usuario))end+'¶'  
                             +@F_cadindicador                                                                                         
    exec @F_error_exec=Construct_GLB
                       @I_mostrar    = 'N',
                       @IO_construct = @F_Condicion_doc  output,
                       @O_error_msg  = @O_error_msg output
				IF @@error <> 0 
							BEGIN
									SET @O_error_msg ='Error al ejecutar Construct_GLB.'
									GOTO Error
							END   
				IF @F_error_exec <> 0 GOTO Error       
       
    insert into #tabla_reporte   
    select 3,7,1,LINEA_TEXTO = cast(a.nombcorto as char(10)) + space(1)+
                str(a.nro_cuenta,12) + space(1)+
                cast(a.nombre_ful as char(35)) + space(1)+ 
                cast(a.siglab as char(20)) + space(1)+
                str(isnull(a.monto,0),13,2) + space(1)+ 
               a.sigla 
           from #temp_bloqueo_cct      as a   
           where  a.bloqueo = 0 
           
           
   insert into #tabla_reporte          
   select 3,7,1,linea_texto = 'TOTAL OPER --> ' + str(isnull(COUNT (a.nro_cuenta),0),10)
           from #temp_bloqueo_cct      as a 
          where a.bloqueo = 0 
           
      set @RowCount=0
      select @RowCount=count(id) from #tabla_reporte where tipo =3 and subtipo=7       
      if @RowCount = 8 --Cantidad de lineas que ocupa el header(7) y footer(1)
      begin 
            update #tabla_reporte set  visible=0 where tipo =3 and subtipo=7        
      end    
------------------------------------------------------------------------------------------------------------------
-- *** FIN MOVIMIENTO DE BLOQUEO DESBLOQUEO CUENTA CORRIENTE
------------------------------------------------------------------------------------------------------------------
-- endregion
-- region dpf
----------------------------------------------------------------------------------------------------
---- MOVIMIENTO DE DEPOSITO A PLAZO FIJO
-----------------------------------------------------------------------------------------------------      
    set @F_Criteriodpf = 'b.cliente§' +case @I_Usuario when 0 then '' 
                                       else ltrim(str(@I_Usuario))end+'¶'+   
                         'b.agencia§' +case @I_agencia when 0 then '' 
                                       else ltrim(str(@I_agencia))end+'¶'                                                  
                        +@F_cadindicador--'b.indicador§'+@I_Indicador+'¶'                                                                        
    exec @F_error_exec=Construct_GLB
                      @I_mostrar    = 'N',
                      @IO_construct = @F_Criteriodpf  output,
                      @O_error_msg  = @O_error_msg output
    IF @@error <> 0 
       BEGIN
       SET @O_error_msg ='Error al ejecutar Construct_GLB.'
       GOTO Error
       END     
				IF @F_error_exec <> 0 GOTO Error      
       
    insert into #tabla_reporte      
    Select 4,1,1,Linea_texto           = ''
    union all Select 4,1,1,Linea_texto = ''
    union all Select 4,1,1,Linea_texto = ''
    union all Select 4,1,1,Linea_texto = '----------------------------------------------------------------------------------------------------------------------------------' 
    union all Select 4,1,1,Linea_texto = 'MOVIMIENTOS DE DEPÓSITO A PLAZO FIJO'
    union all Select 4,1,1,Linea_texto = '----------------------------------------------------------------------------------------------------------------------------------' 
  
    insert into @tb_temporal_dpf
    -- region consulta_dpf
    EXEC( ' select a.comprobante,301 as cod_tran, a.usuario,a.nro_cuenta,a.fraccion, '+
          '       a.cap_desemb as capital,0 as interes,a.indicador,1,nit,retiene_iva,'+
          '       isnull((select g.descripcion                                                                               '+
          '                 from dpfmst_envio_edv as f,                                                                      '+
          '                      pam_tablas as g                                                                             '+
          '                where f.indicador  = ''A''                                                                        '+
          '                  and f.cod_envio_edv     = 1 '+ --alta                                                             
          '                  and f.estado_envio = g.codigo                                                                   '+
          '                  and ( (f.comprobante > 0 and f.comprobante = a.comprobante)                                     '+
          '                   or(f.comprobante = 0 and a.nro_cuenta   = f.nro_cuenta and a.fecha_proceso = f.fecha_proceso)  '+
          '                    )                                                                                             '+
          '                  and g.tabla        = 195                                                                        '+
          '                  and g.indicador    = ''A''                                                                      '+
          '                  and g.fecha_proceso_hasta = ''01-01-2050''),'''')                                               '+
          ' from dpftrn_desemb as a WITH (NOLOCK) ,                                                                          '+
          '      climov_usuario as b WITH (NOLOCK),                                                                          '+
          '      climst_clioper as c WITH (NOLOCK),                                                                          '+
          '      climst_cliente as d WITH (NOLOCK),                                                                          '+
          '      dpfmst_saldia  as e WITH (NOLOCK)                                                                           '+
          ' where a.fecha_proceso  = '+ @F_fecha +
          '   and '+ @F_Criteriodpf+
          '    and a.usuario = b.cliente '+
          '    and b.indicador = ''A''   '+
          '    and a.fecha_proceso between b.fecha_proceso and b.fecha_proceso_hasta ' +
             ' and c.nro_cuenta = a.nro_cuenta ' +  
             ' and c.fecha_proceso_hasta = ''01/01/2050''' +
             ' and c.sistema = 300 ' +  
             ' and c.tipo_rel = 4 ' +  
             ' and c.sec = 1 ' +  
             ' and d.cliente = c.cliente ' +
             ' and d.fecha_proceso_hasta = ''01/01/2050''' +
             ' and d.indicador = ''A''' +
             ' and e.nro_cuenta = a.nro_cuenta ' +
             ' and a.fecha_proceso between e.fecha_proceso and e.fecha_proceso_hasta ' +                          
           ' union all  ' + 
           ' select  a.comprobante,a.cod_tran, a.usuario,a.nro_cuenta,a.fraccion,                                                   ' + 
           '         a.capital,a.interes,a.indicador,2,nit,retiene_iva,                                             ' + 
           '         isnull((select g.descripcion                                                                                   ' + 
           '                   from dpfmst_envio_edv as f,                                                                          ' + 
           '                        pam_tablas as g                                                                                 ' + 
           '                  where f.indicador  = ''A''                                                                            ' + 
           '                   and f.cod_envio_edv     = 4 '+    --antes estaba con 2                                                
           '                   and ( (f.comprobante > 0 and f.comprobante = a.comprobante)                                          ' + 
           '                       or(f.comprobante = 0 and a.nro_cuenta   = f.nro_cuenta and a.fecha_proceso = f.fecha_proceso)    ' + 
           '                        )                                                                                               ' + 
           '                   and f.estado_envio = g.codigo                                                                        ' + 
           '                   and g.tabla        = 195                                                                             ' + 
           '                   and g.indicador    = ''A'' ' + 
           '                   and g.fecha_proceso_hasta = ''01-01-2050''),'''')' +
             ' from dpftrn_pagos as a WITH (NOLOCK),     ' + 
           '         climov_usuario as b WITH (NOLOCK),   ' + 
           '         climst_clioper as c WITH (NOLOCK),   ' + 
           '         climst_cliente as d WITH (NOLOCK),   ' + 
           '         dpfmst_saldia  as e WITH (NOLOCK)    ' + 
           ' where a.fecha_proceso  ='+ @F_fecha +
           '   and '+ @F_Criteriodpf+ 
           '   and a.cod_tran=303                                                     ' + 
           '   and a.usuario = b.cliente                                            ' + 
           '   and b.indicador = ''A''                                              ' + 
           '   and a.fecha_proceso between b.fecha_proceso and b.fecha_proceso_hasta ' +
           '   and c.nro_cuenta = a.nro_cuenta                  ' + 
           '   and c.fraccion = a.fraccion                    ' + 
           '   and c.fecha_proceso_hasta = ''01/01/2050''     ' + 
           '   and c.sistema = 300                            ' + 
           '   and c.tipo_rel = 4                             ' + 
           '   and c.sec = 1                                  ' + 
           '   and d.cliente = c.cliente                      ' + 
           '   and d.fecha_proceso_hasta = ''01/01/2050''     ' + 
           '   and d.indicador = ''A''                        ' + 
           '   and e.nro_cuenta = a.nro_cuenta                ' + 
           '   and e.fraccion = a.fraccion                    ' + 
           '   and a.fecha_proceso between e.fecha_proceso and e.fecha_proceso_hasta '+                        
           ' union all ' + 
           '  select a.comprobante,a.cod_tran, a.usuario,a.nro_cuenta,a.fraccion,                                                ' + 
           '         a.capital,a.interes,a.indicador,3,nit,retiene_iva,                                          ' + 
           '         isnull((select g.descripcion                                                                                ' + 
           '                   from dpfmst_envio_edv as f,                                                                       ' + 
           '                        pam_tablas as g                                                                              ' + 
           '                  where f.indicador  = ''A''                                                                         ' + 
           '                   and f.cod_envio_edv  = 1 '+ --como apertura para edv                                                 ' + 
           '                   and ( (f.comprobante > 0 and f.comprobante = a.comprobante)                                       ' + 
           '                       or(f.comprobante = 0 and a.nro_cuenta   = f.nro_cuenta and a.fecha_proceso = f.fecha_proceso) ' + 
           '                        )                                                                                            ' + 
           '                   and f.estado_envio = g.codigo                                                                     ' + 
           '                   and g.tabla        = 195                                                                          ' + 
           '                   and g.indicador    = ''A''                                                                        ' + 
           '                   and g.fecha_proceso_hasta = ''01-01-2050''),'''')                                                 ' + 
           ' from dpftrn_pagos as a WITH (NOLOCK),       ' + 
           '         climov_usuario as b WITH (NOLOCK),   ' + 
           '         climst_clioper as c WITH (NOLOCK),   ' + 
           '         climst_cliente as d WITH (NOLOCK),   ' + 
           '         dpfmst_saldia  as e WITH (NOLOCK)    ' + 
           ' where a.fecha_proceso = '+ @F_fecha + 
             ' and '+ @F_Criteriodpf+ 'and a.cod_tran=313                                ' + 
             ' and a.usuario = b.cliente                                                 ' + 
             ' and b.indicador = ''A''                                                   ' + 
             ' and a.fecha_proceso between b.fecha_proceso and b.fecha_proceso_hasta     ' + 
             ' and c.nro_cuenta = a.nro_cuenta                                           ' + 
             ' and c.fraccion = a.fraccion                                               ' + 
             ' and c.fecha_proceso_hasta = ''01/01/2050''                                ' + 
             ' and c.sistema = 300                                                       ' + 
             ' and c.tipo_rel = 4                                                        ' + 
             ' and c.sec = 1                                                             ' + 
             ' and d.cliente = c.cliente                                                 ' + 
             ' and d.fecha_proceso_hasta = ''01/01/2050''                                ' + 
             ' and d.indicador = ''A''                                                   ' + 
             ' and e.fraccion = a.fraccion                                               ' + 
             ' and e.nro_cuenta = a.nro_cuenta  ' +
             ' and a.fecha_proceso between e.fecha_proceso and e.fecha_proceso_hasta '+            
           ' union all ' + 
             'select a.comprobante,a.cod_tran, a.usuario,a.nro_cuenta,a.fraccion,         ' + 
             '       a.capital,a.interes,a.indicador,4,nit,retiene_iva,   ' +                 
             '       isnull((select g.descripcion                                         ' + 
             '                 from dpfmst_envio_edv as f,                                ' + 
             '                      pam_tablas as g                                       ' + 
             '                where f.indicador  = ''A''                                  ' + 
             '                 and f.cod_envio_edv = 1 '+--como apertura para edv           ' + 
             '                 and f.comprobante = a.comprobante                          ' + 
             '                 and f.estado_envio = g.codigo                              ' + 
             '                 and g.tabla        = 195                                   ' + 
             '                 and g.indicador    = ''A''                                 ' + 
             '                 and g.fecha_proceso_hasta = ''01-01-2050''),'''')' +
             ' from dpftrn_pagos as a WITH (NOLOCK),                                        ' + 
             '      climov_usuario as b WITH (NOLOCK),                                      ' + 
             '      climst_clioper as c WITH (NOLOCK),                                      ' + 
             '      climst_cliente as d WITH (NOLOCK),                                      ' + 
             '      dpfmst_saldia  as e WITH (NOLOCK)                                       ' + 
             'where a.fecha_proceso  = '+ @F_fecha +
             '  and '+ @F_Criteriodpf+ 
             '  and a.cod_tran=314                                                          ' + 
             '  and a.usuario = b.cliente                                                   ' + 
             '  and b.indicador = ''A''                                                     ' + 
             '  and a.fecha_proceso between b.fecha_proceso and b.fecha_proceso_hasta       ' + 
             '  and c.nro_cuenta = a.nro_cuenta                                             ' + 
             '   and c.fraccion = a.fraccion                                                ' + 
             '  and c.fecha_proceso_hasta = ''01/01/2050''                                  ' + 
             '  and c.sistema = 300                                                         ' + 
             '  and c.tipo_rel = 4                                                          ' + 
             '  and c.sec = 1                                                               ' + 
             '  and d.cliente = c.cliente                                                   ' + 
             '  and d.fecha_proceso_hasta = ''01/01/2050''                                  ' + 
             '  and d.indicador = ''A''                                                     ' + 
             '  and e.fraccion = a.fraccion                                                 ' + 
             '  and e.nro_cuenta = a.nro_cuenta ' +
             '  and a.fecha_proceso between e.fecha_proceso and e.fecha_proceso_hasta '+              
             '  union all ' +                                                                                                        
             'select a.comprobante,a.cod_tran, a.usuario,a.nro_cuenta,a.fraccion,                                                    ' + 
             '       a.capital, a.interes,  a.indicador, 5, nit,retiene_iva,                                         ' + 
             '       isnull((select g.descripcion                                                                                    ' + 
             '                 from dpfmst_envio_edv as f,                                                                           ' + 
             '                      pam_tablas as g                                                                                  ' + 
             '                where f.indicador  = ''A''                                                                             ' + 
             '                 and f.cod_envio_edv     =3 '+ --pago de interes                                                         
             '                 and ( (f.comprobante > 0 and f.comprobante = a.comprobante)                                           ' + 
             '                     or(f.comprobante = 0 and a.nro_cuenta   = f.nro_cuenta and a.fecha_proceso = f.fecha_proceso)     ' + 
             '                      )                                                                                                ' + 
             '                 and f.estado_envio = g.codigo                                                                         ' + 
             '                 and g.tabla        = 195                                                                              ' + 
             '                 and g.indicador    = ''A''                                                                            ' + 
             '                 and g.fecha_proceso_hasta = ''01-01-2050''),'''')'+
             ' from dpftrn_pagos as a WITH (NOLOCK),    ' + 
             '      climov_usuario as b WITH (NOLOCK),  ' + 
             '      climst_clioper as c WITH (NOLOCK),  ' + 
             '      climst_cliente as d WITH (NOLOCK),  ' + 
             '      dpfmst_saldia  as e WITH (NOLOCK)   ' + 
             'where a.fecha_proceso = '+ @F_fecha + 
             '  and '+ @F_Criteriodpf + 
             '  and a.usuario = b.cliente                                               ' + 
             '  and b.indicador = ''A''                                                 ' + 
             '  and a.fecha_proceso between b.fecha_proceso and b.fecha_proceso_hasta   ' + 
             '  and  a.cod_tran=302                                                     ' + 
             '  and c.fraccion = a.fraccion                                             ' + 
             '  and c.nro_cuenta = a.nro_cuenta                                         ' + 
             '  and c.fecha_proceso_hasta = ''01/01/2050''                              ' + 
             '  and c.sistema = 300                                                     ' + 
             '  and c.tipo_rel = 4                                                      ' + 
             '  and c.sec = 1                                                           ' + 
             '  and d.cliente = c.cliente                                               ' + 
             '  and d.fecha_proceso_hasta = ''01/01/2050''                              ' + 
             '  and d.indicador = ''A''                                                 ' + 
             '  and e.fraccion = a.fraccion                                             ' + 
             '  and e.nro_cuenta = a.nro_cuenta ' +
             ' and a.fecha_proceso between e.fecha_proceso and e.fecha_proceso_hasta '+              
           ' order by 10 ' )
    -- endregion  

  	select  @F_maxsec =max(id), @F_count=min(id) from @tb_temporal_dpf
  	select @F_count =isnull(@F_count,1),
          @F_maxsec =isnull(@F_maxsec,0),
          @F_Cod_Tran_aux    = 0,
          @F_Total_Comp      = 0,
          @F_SubTotal_Comp   = 0,
          @F_Comprobante_aux = 0,
          @F_Total_int       = 0,
          @F_Total_cap       = 0,
          @F_Total_ef        = 0,
          @F_Total_con       = 0,
          @F_Total_ah        = 0
  	while (@F_count <= @F_maxsec)             
     BEGIN
   	 select @F_comprobante =comprobante,
            @F_cod_tran    =cod_tran   ,
            @F_usuario     =usuario    ,
            @F_nro_cuenta  =nro_cuenta ,
            @F_fraccion    =fraccion   ,
            @F_capital     =capital    ,
            @F_interes     =interes    ,
            @F_indicador   =indicador  ,
            @F_num         =num        ,
            @F_ci_nit      =ci_nit     ,
            @F_retiene_iva =retiene_iva,
            @F_Descrip_dpf =Descrip_dpf      
      	from @tb_temporal_dpf t
      where t.id = @F_count  
      
     select @F_mto_ahorro    = 0,
            @F_mto_efectivo  = 0,
            @F_mto_contable  = 0
                  
     select @F_nombcorto = nombcorto ,
            @F_agencia   = agencia
       from climst_usuario  WITH (NOLOCK)
      where cliente = @F_usuario
        and indicador ='A'
        
     select @F_codigo_cliente = cliente 
       from climst_clioper WITH (NOLOCK)
      where nro_cuenta = @F_nro_cuenta
        and fecha_proceso_hasta ='01-01-2050'
        and sistema=300 and sec=1   
          
     select @F_sigla_moneda = sigla 
       from pam_moneda m WITH (NOLOCK), dpfmst_maestro x  WITH (NOLOCK)
      where x.nro_cuenta = @F_nro_cuenta
        and x.indicador='A'
        and x.moneda=m.moneda and m.indicador='A'
        
     select @F_descripcion = descripcion 
       from pam_codtran WITH (NOLOCK)
      where sistema =300
        and cod_tran= @F_cod_tran 
        and indicador='A'
          
     set @F_contestado = 0
     select @F_contestado = contestado 
       from cajtrn_puente WITH (NOLOCK)
       where comprobante = @F_comprobante
        and agencia = @F_agencia
        and indicador ='A'
        and sistema = 300 

     if @F_cod_tran in (301,303,304,306)
       BEGIN
           select @F_tasa=tasa,
                  @F_plazo=plazo,
                  @F_lapso=lapso
             FROM dpfmst_saldia WITH (NOLOCK)
            where nro_cuenta=@f_nro_cuenta
              and @z_fecha_proceso between fecha_proceso AND fecha_proceso_hasta
          set @F_rowcount=@@rowcount
          IF @@error <> 0 
             BEGIN
             SET @O_error_msg ='Error al leer tabla dpfmst_saldia.'
             GOTO Error
             END   
          if @F_rowcount=0
            BEGIN
               select @F_plazo=plazo,
                      @F_lapso=lapso
                 FROM dpfmst_maestro WITH (NOLOCK)
                where nro_cuenta=@f_nro_cuenta
               set @F_rowcount=@@rowcount
               IF @@error <> 0 
               or @F_rowcount=0
                BEGIN
                    SET @O_error_msg ='Error al leer tabla dpfmst_maestro.'
                    GOTO Error
                END               
               select @F_tasa=tasa
                 FROM dpfmst_tasas WITH (NOLOCK)
                where nro_cuenta=@f_nro_cuenta
                  and @z_fecha_proceso between fecha_proceso AND fecha_proceso_hasta
               set @F_rowcount=@@rowcount
               IF @@error <> 0 
               or @F_rowcount=0
                  BEGIN
                    SET @O_error_msg ='Error al leer tabla dpfmst_tasas.' + cast(@f_nro_cuenta as varchar(7))
                    GOTO Error
                  END               
            END   
          exec @error_exec=Leer_viaspagos_DPF
                            @I_comprobante   = @F_comprobante,
                            @O_mto_ahorro    = @F_mto_ahorro   output,
                            @O_mto_efectivo  = @F_mto_efectivo output,
                            @O_mto_contable  = @F_mto_contable output,
                            @O_error_msg     = @O_error_msg    output
          IF @@error <> 0 
             BEGIN
             SET @O_error_msg ='Error al ejecutar Leer_viaspagos_DPF.'
             GOTO Error
             END   
          IF @error_exec <> 0 GOTO Error
       END  
     if @F_cod_tran in (302)
        BEGIN
           exec @error_exec=Leer_viaspagos_DPF
                             @I_comprobante   = @F_comprobante,
                             @O_mto_ahorro    = @F_mto_ahorro   output,
                             @O_mto_efectivo  = @F_mto_efectivo output,
                             @O_mto_contable  = @F_mto_contable output,
                             @O_error_msg     = @O_error_msg    output
          IF @@error <> 0 
             BEGIN
               SET @O_error_msg ='Error al ejecutar Leer_viaspagos_DPF.'
               GOTO Error
             END   
          IF @error_exec <> 0 GOTO Error
        END  
     if @F_Cod_Tran_aux <> @F_Cod_tran
        begin
           insert into #tabla_reporte  
           select 4,1,1,linea_texto = ''
           union all select 4,1,1,linea_Texto = isnull(@F_Descripcion,'')                 
           
           select @F_Encabezado = case @F_Cod_Tran when 301 then 'USUARIO' + SPACE(5) + 'COMPROBANTE'+space(7)+'CODIGO'+space(1)+'CUENTA'+space(2)+'FRAC.'+SPACE(12)+'MONTO'+space(1)+'MONEDA'+space(1)+'TASA'+space(1)+ 'PLAZO'+space(1)+'LAP'+space(16)+'AHORRO'+SPACE(14)+'EFECTIVO'+SPACE(10)+'CONTAB.'+SPACE(1)+'PROC.CAJA '+space(2)+'ESTADO'+space(2)+'RETIENE IVA?'+SPACE(2)+'ESTADO EDV'
                                                   when 303 then 'USUARIO' + SPACE(5) + 'COMPROBANTE'+space(7)+'CODIGO'+space(1)+'CUENTA'+space(2)+'FRAC.'+SPACE(12)+'MONTO'+space(1)+'MONEDA'+space(1)+'TASA'+space(1)+ 'PLAZO'+space(1)+'LAP'+space(16)+'AHORRO'+SPACE(14)+'EFECTIVO'+SPACE(10)+'CONTAB.'+SPACE(1)+'PROC.CAJA '+space(2)+'ESTADO'+space(2)+'RETIENE IVA?'+SPACE(2)+'ESTADO EDV'
                                                            else 'USUARIO' + SPACE(5) + 'COMPROBANTE'+space(7)+'CODIGO'+space(1)+'CUENTA'+space(2)+'FRAC.'+SPACE(8)+'INTERES'+space(1)+'MONEDA'+space(12)+'AHORRO'+SPACE(20)+'EFECTIVO'+SPACE(10)+'CONTAB.'+SPACE(6)+ 'PROC.CAJA '+space(3)+'ESTADO'+space(2)+'RETIENE IVA?'+SPACE(2)+'ESTADO EDV'
                                   end       
           insert into #tabla_reporte 
           select 4,1,1,linea_texto = @F_Encabezado
           union all select 4,1,1,linea_texto = replicate('-',len(@F_Encabezado)+1)
           
           set @F_Cod_Tran_aux = @F_Cod_tran
           select @F_SubTotal_Comp = 0,
                  @F_SubTotal_int    = 0,
                  @F_SubTotal_cap    = 0,     
                  @F_SubTotal_ef     = 0,
                  @F_SubTotal_con    = 0,
                  @F_SubTotal_ah     = 0
        end
     if @F_Comprobante <> @F_Comprobante_aux
        begin
           set @F_Total_Comp = @F_Total_Comp + 1 
           set @F_SubTotal_Comp = @F_SubTotal_Comp + 1
           set @F_Comprobante_aux = @F_Comprobante
           select @F_SubTotal_int    = @F_SubTotal_int + @F_interes,
                  @F_SubTotal_cap    = @F_SubTotal_cap + @F_capital,
                  @F_SubTotal_ef     = @F_SubTotal_ef  + @F_mto_efectivo,
                  @F_SubTotal_con    = @F_SubTotal_con + @F_mto_contable,
                  @F_SubTotal_ah     = @F_SubTotal_ah  + @F_mto_ahorro   
           select @F_Total_int    = @F_Total_int + @F_interes,
                  @F_Total_cap    = @F_Total_cap + @F_capital,
                  @F_Total_ef     = @F_Total_ef  + @F_mto_efectivo,
                  @F_Total_con    = @F_Total_con + @F_mto_contable,
                  @F_Total_ah     = @F_Total_ah  + @F_mto_ahorro
           if @F_cod_Tran in (301,303) /*301 = APERTURA DPF  303=CANCELACION DPF*/  
              begin
                 select @F_Detalle = CAST(isnull(@F_nombcorto,'') AS char(10))  +space(3) + 
                                     dbo.Fn_FormatoComprobante_GLB(@F_comprobante)+space(1)+
                                     str(isnull(@F_codigo_cliente,0)) + space(1)+
                                     cast(@F_nro_cuenta as char(8))+space(1)+CAST(@f_fraccion as CHAR(2))+ SPACE(1)+
                                     dbo.Fn_Monto_Dinero_GLB(isnull(@F_capital,0))+space(1)+
                                     cast(ISNULL(@F_sigla_moneda,'') as char(5))+space(1)+
                                     str(isnull(@F_tasa,0),6,2) + space(1)+ 
                                     str(isnull(@F_plazo,0),4)+space(1)+
                                     str(isnull(@F_lapso,0),6)+space(5)+
                                     dbo.Fn_Monto_Dinero_GLB(isnull(@F_mto_ahorro,0))   + space(1)+
                                     dbo.Fn_Monto_Dinero_GLB(isnull(@F_mto_efectivo,0)) + space(1)+
                                     dbo.Fn_Monto_Dinero_GLB(isnull(@F_mto_contable,0)) + space(5)+ 
                                     case when @F_contestado = 0 then 'NO' 
                                          when @F_contestado = 2 then 'NA' else 'SI' END+SPACE(10)+LTRIM(@F_indicador) + space(7)+ 
                                     case when @F_retiene_iva = 1 then 'SI' else 'NO' end+SPACE(10)+@F_Descrip_dpf
              end
            if @F_Cod_Tran NOT in (301,303,304,307)
               begin
                  select @F_Detalle = CAST(isnull(@F_nombcorto,'') AS CHAR(10)) +  space(2)+ 
                                      dbo.Fn_FormatoComprobante_GLB(@F_comprobante)+space(1)+
                                      str(isnull(@F_codigo_cliente,0)) + space(1)+
                                      cast(@F_nro_cuenta as char(7))+space(1)+ CAST(@f_fraccion as CHAR(2))+ SPACE(1)+
                                      dbo.Fn_Monto_Dinero_GLB(isnull(@F_interes,0)) +space(1)+
                                      cast(@F_sigla_moneda as char(5))+space(1)+
                                      dbo.Fn_Monto_Dinero_GLB(isnull(@F_mto_ahorro,0))   + space(10)+
                                      dbo.Fn_Monto_Dinero_GLB(isnull(@F_mto_efectivo,0)) + space(1)+ 
                                      dbo.Fn_Monto_Dinero_GLB(isnull(@F_mto_contable,0)) + space(8)+ 
                                      Case when @F_contestado = 0 then 'NO' 
                                           when @F_contestado = 2 then 'NA' else 'SI' END+SPACE(10)+LTRIM(@F_indicador)+ space(7)+ 
                                      Case when @F_retiene_iva = 1 then 'SI' else 'NO' end+SPACE(10)+@F_Descrip_dpf
               end
               
               
           insert into #tabla_reporte  
           select 4,1,1,Linea_texto =  @F_Detalle
        end 
     SET  @F_count=@F_count+1      
     if @F_Cod_Tran_aux <> @F_Cod_tran
     or (@F_count >  @F_maxsec) 
        begin
           if @F_Cod_Tran_aux in (301,303) /*301 = RET_APERT_DPF , DEP_CANCEL_DPF */  
              begin
                 insert into #tabla_reporte  
                 select 4,1,1,Linea_texto =space(54)+'=============                                =============        =============    ============='
                 union all
                 select 4,1,1,linea_texto =' TOTAL OPER: '+str(@F_SubTotal_Comp,3)+space(34)+ dbo.Fn_Monto_Dinero_GLB(@F_SubTotal_cap)+space(27)+
                                       dbo.Fn_Monto_Dinero_GLB(@F_SubTotal_ah)+space(1)+dbo.Fn_Monto_Dinero_GLB(@F_SubTotal_ef) +space(1)+
                                       dbo.Fn_Monto_Dinero_GLB(@F_SubTotal_con) 
              end 
            if @F_Cod_Tran_aux = 304        /*304 = RENOV_AUTO_DPF*/
               begin
                 insert into #tabla_reporte  
                 select 4,1,1,Linea_texto =space(52)+'============='
                 union all
                 select 4,1,1,linea_texto =' TOTAL OPER: '+str(@F_SubTotal_Comp,3)+space(21)+ dbo.Fn_Monto_Dinero_GLB(@F_SubTotal_cap) 
               end 
            if @F_Cod_Tran_aux = 307       /*307  = DEVENG_DPF*/  
               begin
                  
                  insert into #tabla_reporte  
                  select 4,1,1,Linea_texto =space(52)+'============='+space(28)+'============= ============= ============='
                  union all
                  select 4,1,1,linea_texto =' TOTAL OPER: '+str(@F_SubTotal_Comp,3) 
               end
            if  @F_Cod_Tran_aux not in(301,303,304,307)  
                begin
                   insert into #tabla_reporte  
                   select 4,1,1,Linea_texto =space(56)+'=============          =============             =============     ============='
                   union all
                   select  4,1,1,linea_texto =' TOTAL OPER: '+str(@F_SubTotal_Comp,3) + space(32)+dbo.Fn_Monto_Dinero_GLB(@F_Total_int)+space(7)+
                                     dbo.Fn_Monto_Dinero_GLB(@F_SubTotal_ah)+space(10)+dbo.Fn_Monto_Dinero_GLB(@F_SubTotal_ef)+space(1)+
                                     dbo.Fn_Monto_Dinero_GLB(@F_SubTotal_con) 
                end         
        end 
    END
      
   insert into #tabla_reporte
   select  4,1,1,linea_Texto = ''
   union all select 4,1,1,linea_texto = space(33)+'TOTAL OPER : '+ str(isnull(@F_Total_Comp,0))
   union all select 4,1,1,linea_Texto = space(33)+'CAPITAL    : '+ dbo.Fn_Monto_dinero_glb(@F_Total_cap) 
   union all select 4,1,1,linea_Texto = space(33)+'INTERES    : '+ dbo.Fn_Monto_Dinero_GLB(@F_Total_int)
   union all select 4,1,1,linea_Texto = space(33)+'TOT. AHORRO: '+ dbo.Fn_Monto_Dinero_GLB(@F_Total_ah)
   union all select 4,1,1,linea_Texto = space(33)+'TOT. EFECTI: '+ dbo.Fn_Monto_Dinero_GLB(@F_Total_ef)
   union all select 4,1,1,linea_Texto = space(33)+'TOT. CONTAB: '+ dbo.Fn_Monto_Dinero_GLB(@F_Total_con)
    
   set @RowCount=0
   select @RowCount=count(id) from #tabla_reporte where tipo =4 and subtipo=1       
   if @RowCount = 13 --Cantidad de lineas que ocupa el header(6) y footer(2)
      update #tabla_reporte set  visible=0 where tipo =4 and subtipo=1       
-----------------------------------------------------------------------------------------------------
---- FIN DEL MOVIMIENTOS DE DEPOSITO A PLAZO FIJO
-----------------------------------------------------------------------------------------------------
-- endregion
-- region tjt_debito
-----------------------------------------------------------------------------------------------------
---- MOVIMIENTOS DE TARJETA DE DEBITO
-----------------------------------------------------------------------------------------------------
     insert into #tabla_reporte  
     Select 5,0,1,Linea_texto           = ''
     union all Select 5,0,1,Linea_texto = ''
     union all Select 5,0,1,Linea_texto = ''
     union all Select 5,0,1,Linea_texto = '----------------------------------------------------------------------------------------------------------------------------------' 
     union all Select 5,0,1,Linea_texto = 'MOVIMIENTOS DE TARJETA DE DÉBITO'
     union all Select 5,0,1,Linea_texto = '----------------------------------------------------------------------------------------------------------------------------------' 
    if @I_Indicador <>''
       set @F_cadindicador ='a.indicador§'+@I_Indicador+'¶'   
    else
       set @F_cadindicador = ''  
    
    set @F_Criterio = 'x.cliente§'  +case @I_Usuario when 0 then '' 
                                    else ltrim(str(@I_Usuario))end+'¶'
                     +'x.agencia§'  +case @I_agencia when 0 then '' 
                                    else ltrim(str(@I_agencia))end+'¶'
                     +@F_cadindicador--'a.indicador§'+@I_Indicador+'¶'                                                    
    exec @F_error_exec=Construct_GLB
                       @I_mostrar    = 'N',
                       @IO_construct = @F_criterio  output,
                       @O_error_msg  = @O_error_msg output
    IF @@error <> 0 
       BEGIN
       SET @O_error_msg ='Error al ejecutar Construct_GLB.'
       GOTO Error
       END   
				IF @F_error_exec <> 0 GOTO Error    
       
    insert into #tabla_reporte              
    select 5,1,1,Linea_texto           = '-----------------------------------------------' 
    union all select 5,1,1,Linea_texto = '###   SOLICITUDES DE APERTURA DE TARJETA    ###'
    union all select 5,1,1,Linea_texto = '-----------------------------------------------' 
    union all select 5,1,1,Linea_texto = ' USUARIO     CÓDIGO    NOMBRE CLIENTE                       NRO. TARJETA     TIPO TARJETA     COMISIÓN     ESTADO         TRANSACCIÓN                             OBSERVACIÓN                                INDICADOR   LIMITE DIARIO INTERNET'
    
    insert into #tabla_reporte 
     exec ('select 5,1,1,linea_texto=cast(isnull (x.nombcorto,'' '') as char(8))+space(3)+ '+
                ' str(f.cliente,8)+ space(4)+'+   
                ' cast(f.nombre_ful as char(35)) + ' + '''  '' + ' +
                	' dbo.fn_tjt_enmascTarjeta(a.nro_tarjeta, ' + @F_EnmascararTjt + ') + ' + '''  '' + ' +
                ' cast((case when a.cod_tran = 265 then ' + '''TJT.ADICIONAL''' + ' else ' + '''TJT.TITULAR''' + ' end ' + ')' + ' as char(14)) + ' + '''  '' + ' +
                ' (case when (exists(select b.comprobante from  tjttrn_cargos as b WITH (NOLOCK)
                                      where b.comprobante = a.comprobante
                                        and b.asume=1)) then ''SI''
                                     else ''NO'' end)+ space(11)+'+
            
                ' cast((select top 1 bx.sigla from tjttrn_tarjeta ax, pamtjt_estado bx where ax.estado=bx.estado '+
                          'and ax.nro_tarjeta= a.nro_tarjeta and ax.fecha_proceso = ' + @F_fecha +
                          ' and ax.cod_tran in (265,266,0) and ax.indicador = ''A'' order by ax.comprobante desc ) as char(11))+space(5) + ' +  
                ' cast(y.descripcion as char(35))+space(4) + ' + 
                ' cast(a.observaciones as char(40))+space(3)+LTRIM(a.indicador) +space(11)+' +

                ' (case when (exists(select b.nro_tarjeta from tjtmst_detLimiteInternet as b 
                                      where b.nro_tarjeta = a.nro_tarjeta
                                      and b.fecha_proceso_hasta=''01-01-2050'' and b.indicador=''A'' and b.tipo_limite=0)) then ''HABILITADO''
                                      else ''DESHABILITADO'' end)+ space(11) '+
             ' FROM tjttrn_tarjeta as a WITH (NOLOCK), '+
                 '  tjtmst_maestro as a1 WITH (NOLOCK), ' +
                 '  tjtmst_saldia as a2 WITH (NOLOCK), ' +
                 '  pamtjt_estado as a3 WITH (NOLOCK), ' +
                 '  climst_cliente as f WITH (NOLOCK), '+
                 '  climov_usuario as x WITH (NOLOCK) ,'+
                 '  pam_codtran as y WITH (NOLOCK) '+
           '  WHERE ' + @F_Criterio +
              ' and a.fecha_proceso = ' + @F_fecha +
              ' and a.cod_tran in (265,266) ' +
              ' and a.indicador = ''A'' ' +
              ' and a2.nro_tarjeta = a.nro_tarjeta ' +
              ' and a.fecha_proceso between a2.fecha_proceso and a2.fecha_proceso_hasta ' +
              ' and a.estado = 1 '+
              ' and a3.estado = a.estado ' + 
              ' and a3.indicador = ''A'' ' +
              ' and a1.nro_tarjeta = a.nro_tarjeta ' +
              ' and a1.indicador = ''A'' ' +
        
              ' and f.cliente = a1.cliente ' +
              ' and a.fecha_proceso between f.fecha_proceso and f.fecha_proceso_hasta ' +
              ' and f.indicador in (''A'',''P'') ' +
              ' and x.indicador = ''A'' ' +
              ' and x.cliente = a.usuario' +
              ' and a.fecha_proceso between x.fecha_proceso and x.fecha_proceso_hasta '+
              ' and a.cod_tran=y.cod_tran'+
              ' and y.sistema = 210' +
              ' and y.indicador = ''A''' +
              ' and y.cod_tran in (265,266)' +
              ' ORDER BY a.fecha_proceso')
              
              
    insert into #tabla_reporte          
    Select 5,1,1,Linea_texto = '' 
    
    insert into #tabla_reporte        
    exec (' SELECT 5,1,1,Linea_texto =''TOTAL DE SOLICITUDES DE APERTURA ----->'' +SPACE(5)+ltrim(STR(COUNT(*)))'+
            ' FROM tjttrn_tarjeta as a WITH (NOLOCK), '+
                '  tjtmst_maestro as a1 WITH (NOLOCK), ' +
                '  tjtmst_saldia as a2 WITH (NOLOCK), ' +
                '  climov_usuario as x WITH (NOLOCK) ' +
          '  WHERE ' + @F_Criterio +
             ' and a.fecha_proceso = ' + @F_fecha + 
             ' and a.cod_tran in (265,266) ' +
             ' and a.indicador = ''A'' ' +
             ' and a2.nro_tarjeta = a.nro_tarjeta ' +
             ' and a.fecha_proceso between a2.fecha_proceso and a2.fecha_proceso_hasta ' +
             ' and a.estado = 1 '+
             ' and x.indicador= ''A'' '+
             ' and x.cliente = a.usuario '+
             ' and a.fecha_proceso between x.fecha_proceso and x.fecha_proceso_hasta '+
             ' and a1.nro_tarjeta = a.nro_tarjeta ' +
             ' and a1.indicador = ''A'' ')

      
      set @RowCount=0
      select @RowCount=count(id) from #tabla_reporte where tipo =5 and subtipo=1       
      if @RowCount = 6 --Cantidad de lineas que ocupa el header(6) y footer(2)
      begin 
            update #tabla_reporte set  visible=0 where tipo =5 and subtipo=1       
      end    
------------------------------------------------------------------------------------------------------------------------   
------ Transferencia - Asignación de tarjetas de débito
------------------------------------------------------------------------------------------------------------------------   
	set @RowCount=0
    select @RowCount=count(id) from #tabla_reporte where tipo =5 and subtipo=12   
           
    if @RowCount = 6--Cantidad de lineas que ocupa el header(6) y footer(2)
    begin 
		update #tabla_reporte set  visible=0 where tipo =5 and subtipo=11                  
	end
	create table #table_asig_transf_tjt (
		id int identity(1,1),
		tipo_lote char(13),
		fecha_alta datetime,
		lote int,
		producto tinyint,
		nombre_producto char(24),
		cantidad_tarjeta int,
		rango char(46),
		usuario int,
		agencia int,
		fecha_recepcion smalldatetime
		--fecha_habilitacion smalldatetime
	)
	insert into #table_asig_transf_tjt
		select case when a.tipo_lote=1 then 'ATC          ' 
					when a.tipo_lote=2 then 'CANALES      ' 
					when a.tipo_lote=4 then 'LINKSER      ' 
					else 'TRANSFERENCIA' end,
			   a.fecha_alta,
			   a.lote,
			   isnull(a.producto,0),
			   case when a.producto=1 then convert(char(24),isnull((select descripcion from pam_tablas where tabla=797 and codigo=1 and indicador='A' and fecha_proceso_hasta='01-01-2050'),''))
					when a.producto=2 then convert(char(24),isnull((select descripcion from pam_tablas where tabla=797 and codigo=2 and indicador='A' and fecha_proceso_hasta='01-01-2050'),''))
					else ' ' end,
			   isnull(a.cant_tarjeta,0),
			   'Desde '+dbo.fn_tjt_enmascTarjeta((select isnull(min(nro_tarjeta),' ') from tjt_lote_tarjeta  WITH (NOLOCK) where lote=a.lote and indicador <> 'R'),@F_EnmascararTjt) + 
			   ' hasta '+dbo.fn_tjt_enmascTarjeta((select isnull(MAX(nro_tarjeta),' ') from tjt_lote_tarjeta  WITH (NOLOCK) where lote=a.lote and indicador <> 'R'),@F_EnmascararTjt),
			   isnull((select top 1 y.usuario from tjt_lote_tarjeta x  WITH (NOLOCK), tjt_recepcion_lote y  WITH (NOLOCK) where x.nro_recepcion=y.nro_recepcion and x.lote =a.lote and y.fecha_proceso=@z_fecha_proceso),0),
			   isnull(a.agencia,0),
			   isnull((select top 1 y.fecha_proceso from tjt_lote_tarjeta x  WITH (NOLOCK), tjt_recepcion_lote y  WITH (NOLOCK) where x.nro_recepcion=y.nro_recepcion and x.lote =a.lote and y.fecha_proceso=@z_fecha_proceso),0)
			   --(select top 1 CONVERT(CHAR(10), x.fecha_alta,105) from tjtmst_lote x, pam_tablas y where x.estado=5 and x.lote=a.lote and x.estado=y.codigo and y.indicador='A' and y.fecha_proceso_hasta='01-01-2050')
		from tjtmst_lote a WITH (NOLOCK), pam_agencia b  WITH (NOLOCK), climst_usuario c  WITH (NOLOCK) 
		where a.agencia=b.agencia 
			and b.indicador='A' 
			and a.estado=3  --2 
			and a.usuario=c.cliente 
			and c.indicador='A'
			and a.fecha_proceso = @z_fecha_proceso

	insert into #tabla_reporte    
	Select 5,12,1,Linea_texto           = ''              
	union all select 5,12,1,Linea_texto = '------------------------------------------------------------------' 
	union all select 5,12,1,Linea_texto = '###   TRANSFERENCIA - ASIGNACIÓN LOTES DE TARJETAS DE DÉBITO   ###'
	union all select 5,12,1,Linea_texto = '------------------------------------------------------------------' 
	union all select 5,12,1,Linea_texto = 'TIPO LOTE       HORA     LOTE    TIPO PLÁSTICO          CANT.TJT   RANGO DESDE - HASTA                              USUARIO'
	union all select 5,12,1,Linea_texto = '-----------------------------------------------------------------------------------------------------------------------------'

	DECLARE @F_condicion_transf varchar(50)=' 1=1 '
	if(ISNULL(@I_Usuario,0)<>0)
		set @F_condicion_transf =  ' and a.usuario= ' +ltrim(str(@I_Usuario))
	else if (ISNULL(@I_agencia,0)<>0)
		set @F_condicion_transf =  ' and a.agencia= ' +ltrim(str(@I_agencia))
	else
		set @F_condicion_transf =  ' and a.usuario= ' +ltrim(str(@I_Usuario)) + ' and a.agencia = ' +ltrim(str(@I_agencia))

	set @F_query = 'select 5,12,1,Linea_texto =  a.tipo_lote +SPACE(3)+
					   CONVERT(CHAR(5), isnull(a.fecha_alta,''00:00''),108) +SPACE(3)+
					   STR(a.lote,6)+SPACE(3)+
					   a.nombre_producto + SPACE(2) +
					   STR(a.cantidad_tarjeta,5)+SPACE(3)+
					   a.rango  +SPACE(3)+
					   isnull((select x.nombcorto from climst_usuario x where x.indicador=''A'' and x.cliente=a.usuario),''          '')
				from #table_asig_transf_tjt a  
				where a.fecha_recepcion='+ @F_fecha + @F_condicion_transf+
			   ' ORDER BY a.agencia asc, a.tipo_lote'
	insert into #tabla_reporte  
		exec(@F_query)  
		
	if dbo.fn_gbl_existe_objeto(2,'#table_asig_transf_tjt')=1 drop table #table_asig_transf_tjt  
------------------------------------------------------------------------------------------------------------------------           
------ Modificacion de limite de Retiro
------------------------------------------------------------------------------------------------------------------------   
    if @I_Indicador <>''
       set @F_cadindicador ='a.indicador§'+@I_Indicador+'¶'   
    else
       set @F_cadindicador = ''  
    
    set @F_Criterio = 'x.cliente§'  +case @I_Usuario when 0 then '' 
                                    else ltrim(str(@I_Usuario))end+'¶'
                     +'x.agencia§'  +case @I_agencia when 0 then '' 
                                    else ltrim(str(@I_agencia))end+'¶'
                     +@F_cadindicador--'a.indicador§'+@I_Indicador+'¶'                                                    
    exec @F_error_exec=Construct_GLB
                       @I_mostrar    = 'N',
                       @IO_construct = @F_criterio  output,
                       @O_error_msg  = @O_error_msg output
    IF @@error <> 0 
       BEGIN
       SET @O_error_msg ='Error al ejecutar Construct_GLB.'
       GOTO Error
       END  
				IF @F_error_exec <> 0 GOTO Error    
       
    insert into #tabla_reporte    
    Select 5,2,1,Linea_texto           = ''                 
    union all select 5,2,1,Linea_texto = '-----------------------------------------------' 
    union all select 5,2,1,Linea_texto = '###   MODIFICACIÓN DE LÍMITE DE RETIRO      ###'
    union all select 5,2,1,Linea_texto = '-----------------------------------------------' 
    union all select 5,2,1,Linea_texto = ' USUARIO     CÓDIGO    NOMBRE CLIENTE                       NRO. TARJETA     TIPO TARJETA     COMISIÓN     ESTADO         TRANSACCIÓN               MONTO_LÍMITE      OBSERVACIÓN                 INDICADOR'
    
    insert into #tabla_reporte  
    exec ('select distinct 5,2,1,Linea_texto = cast(isnull (x.nombcorto,'' '') as char(8))+space(3)+ '+
                ' str(f.cliente,8)+ space(4)+'+  
                ' cast(f.nombre_ful as char(35)) + ' + '''  '' + ' +  
                ' dbo.fn_tjt_enmascTarjeta(a.nro_tarjeta, ' + @F_EnmascararTjt + ') + ' + '''  '' + ' +
                ' cast((case when a.cod_tran = 265 then ' + '''TJT.ADICIONAL''' + ' else ' + '''TJT.TITULAR''' + ' end ' + ')' + ' as char(14)) + ' + '''  '' + ' +
                ' ''NO''+ space(11)+'+
                ' cast(a3.sigla as char(11))+space(5) + ' +  
                ' cast(y.descripcion as char(20))+space(4) + ' + 
                ' str(z.monto,10,2)+space(6)  + ' + --RD-5242 ' str(z.saldo_monto,10,2)+space(6)  + '
                ' (select top 1 cast(k.observaciones as char(35)) from tjttrn_tarjeta k WITH (NOLOCK)
                    where k.nro_tarjeta=a.nro_tarjeta 
                     order by fecha_alta desc)+space(3)+ltrim(a.indicador)'+
             ' FROM tjttrn_tarjeta as a WITH (NOLOCK), '+
                 '  tjtmst_maestro as a1 WITH (NOLOCK), ' +
                 '  tjtmst_saldia as a2 WITH (NOLOCK), ' +
                 '  pamtjt_estado as a3 WITH (NOLOCK), ' +
                 --'  tjtrel_cuenta as c WITH (NOLOCK), '+
                 '  climst_cliente as f WITH (NOLOCK), '+
                 '  climov_usuario as x WITH (NOLOCK), '+
                 '  pam_codtran as y WITH (NOLOCK), '+
                 '  tjtmst_limite as z WITH (NOLOCK) '+
           '  WHERE ' + @F_Criterio +
              ' and a.fecha_proceso =' + @F_fecha + 
              ' and a.cod_tran in (270) ' +
              ' and a.indicador = ''A'' ' +
              ' and a2.nro_tarjeta = a.nro_tarjeta ' +
              ' and a.fecha_proceso between a2.fecha_proceso and a2.fecha_proceso_hasta ' +
              ' and a.estado = 2 '+
              ' and a3.estado = a.estado ' + 
              ' and a3.indicador = ''A'' ' +
              ' and a1.nro_tarjeta = a.nro_tarjeta ' +
              ' and a1.indicador = ''A'' ' +
             
              ' and f.cliente = a1.cliente ' +
              ' and a.fecha_proceso between f.fecha_proceso and f.fecha_proceso_hasta ' +
              ' and f.indicador in (''A'',''P'') ' +
              ' and x.indicador = ''A'' ' +
              ' and x.cliente = a.usuario' +
              ' and a.fecha_proceso between x.fecha_proceso and x.fecha_proceso_hasta '+
              ' and y.cod_tran=a.cod_tran' + 
              ' and y.sistema = 210' +
              ' and y.indicador = ''A'' ' +
              ' and y.cod_tran in (270)'+
              ' and z.nro_tarjeta=a.nro_tarjeta '+
              ' and z.indicador=''A'' '+
              ' and z.tipo_tran=0 '+ --tipo transaccion 0=salida(retiro,tranfer,pos) 1=entrada(deposito)
              ' and z.fecha_proceso_hasta=''01-01-2050'' ')    
              
    insert into #tabla_reporte                     
    Select 5,2,1,Linea_texto = ''    
    
    insert into #tabla_reporte      
    exec (' SELECT 5,2,1,Linea_texto =''MODIFICACION DE LIMITE DE RETIRO      ----->'' +SPACE(5)+ ltrim(STR(COUNT(distinct a.nro_tarjeta)))'+
             ' FROM tjttrn_tarjeta as a WITH (NOLOCK), '+
                 '  tjtmst_maestro as a1 WITH (NOLOCK), ' +
                 '  tjtmst_saldia as a2 WITH (NOLOCK), ' +
                 '  climov_usuario as x WITH (NOLOCK)'+
           '  WHERE ' + @F_Criterio +
              ' and a.fecha_proceso = ' + @F_fecha + 
              ' and a.cod_tran in (270) ' +
              ' and a.indicador = ''A'' ' +
              ' and a2.nro_tarjeta = a.nro_tarjeta ' +
              ' and a.fecha_proceso between a2.fecha_proceso and a2.fecha_proceso_hasta ' +
              ' and a.estado = 2 '+
              ' and a.usuario = x.cliente '+
              ' and x.indicador=''A'' '+
              ' and a.fecha_proceso between x.fecha_proceso and x.fecha_proceso_hasta '+
              ' and a1.nro_tarjeta = a.nro_tarjeta ' +
              ' and a1.indicador = ''A'' group by a.cod_tran ')
              
              
      set @RowCount=0
      select @RowCount=count(id) from #tabla_reporte where tipo =5 and subtipo=2   
           
      if @RowCount = 6--Cantidad de lineas que ocupa el header(6) y footer(2)
      begin 
            update #tabla_reporte set  visible=0 where tipo =5 and subtipo=2                  
      end    
 
------------------------------------------------------------------------------------------------------------------------
------ Modificacion de limite de Deposito por cliente
------------------------------------------------------------------------------------------------------------------------   
if @I_Indicador <>''
 set @F_cadindicador ='a.indicador§'+@I_Indicador+'¶'   
else
 set @F_cadindicador = ''  
    
set @F_Criterio = 'x.cliente§'  +case @I_Usuario when 0 then '' 
                              else ltrim(str(@I_Usuario))end+'¶'
               +'x.agencia§'  +case @I_agencia when 0 then '' 
                              else ltrim(str(@I_agencia))end+'¶'
               +@F_cadindicador--'a.indicador§'+@I_Indicador+'¶'                                                    
exec @F_error_exec=Construct_GLB
                 @I_mostrar    = 'N',
                 @IO_construct = @F_criterio  output,
                 @O_error_msg  = @O_error_msg output
IF @@error <> 0 
 BEGIN
 SET @O_error_msg ='Error al ejecutar Construct_GLB.'
 GOTO Error
 END  
IF @F_error_exec <> 0 GOTO Error    
       
insert into #tabla_reporte    
Select 5,7,1,Linea_texto           = ''                 
union all select 5,7,1,Linea_texto = '----------------------------------------------------------' 
union all select 5,7,1,Linea_texto = '###   MODIFICACIÓN DE LÍMITE DE DEPÓSITO POR CLIENTE   ###'
union all select 5,7,1,Linea_texto = '----------------------------------------------------------' 
union all select 5,7,1,Linea_texto = 'USUARIO   |CÓDIGO    |NOMBRE CLIENTE                     |DETALLE                     |MONTO_LÍMITE |OBSERVACIÓN                                      |'
    
insert into #tabla_reporte  
exec ('select distinct 5,7,1,'+
             'Linea_texto = cast(isnull((select top 1 nombcorto from climov_usuario where cliente=b.usuario and b.fecha_proceso between fecha_proceso and fecha_proceso_hasta order by fecha_alta desc),'''') as char(10)) +space(1)+ ' +
                           'cast(isnull(a.cliente,0) as char(10))+space(1)+ ' +
                           'cast(isnull(a.nombre_ful,'''') as char(35))+space(1)+ ' +
                           'cast(isnull((select descripcion from pam_tablas where tabla=737 and codigo=1 and indicador=''A'' and fecha_proceso_hasta=''01-01-2050''),'''') as char(28))+space(1)+ '+
                           'str(isnull(b.monto,0),13,2)+space(1)+ '+
                           'cast(isnull(b.observaciones,'''') as char(50))+space(1) ' +
        'from climst_cliente a WITH (NOLOCK) '+
        'inner join tjtmst_LimiteDeposito b WITH (NOLOCK) on a.cliente= b.cliente ' +
        'inner join climov_usuario as x WITH (NOLOCK) on x.cliente=b.usuario'+
     '  WHERE ' + @F_Criterio +
         'and b.fecha_proceso= ' + @F_fecha +
         'and b.tipo_registro=1 '+
         'and a.indicador in (''A'',''P'')  '+
         'and b.fecha_proceso between a.fecha_proceso and a.fecha_proceso_hasta '+
         'and x.indicador = ''A'' ' +
         'and b.fecha_proceso between x.fecha_proceso and x.fecha_proceso_hasta '
)
              
insert into #tabla_reporte                     
Select 5,7,1,Linea_texto = ''    
    
insert into #tabla_reporte      
exec (' SELECT 5,7,1,Linea_texto =''MODIFICACION DE LIMITE DE DEPOSITO      ----->'' +SPACE(5)+ ltrim(STR(COUNT(distinct b.cliente)))'+
         'from climst_cliente a WITH (NOLOCK) '+
        'inner join tjtmst_LimiteDeposito b WITH (NOLOCK) on a.cliente= b.cliente ' +
        'inner join climov_usuario as x WITH (NOLOCK) on x.cliente=b.usuario'+
      '  WHERE ' + @F_Criterio +
          'and b.fecha_proceso= ' + @F_fecha +
          'and b.tipo_registro=1 '+
          'and a.indicador in (''A'',''P'')  '+
          'and b.fecha_proceso between a.fecha_proceso and a.fecha_proceso_hasta '+
          'and x.indicador = ''A'' ' +
          'and b.fecha_proceso between x.fecha_proceso and x.fecha_proceso_hasta '
)
set @RowCount=0
select @RowCount=count(id) from #tabla_reporte where tipo =5 and subtipo=7   
           
if @RowCount = 6--Cantidad de lineas que ocupa el header(6) y footer(2)
begin 
      update #tabla_reporte set  visible=0 where tipo =5 and subtipo=7                  
end       

------------------------------------ 
------------------------------------------------------------------------------------------------------------------------
------ Modificacion de limite temporal internet
------------------------------------------------------------------------------------------------------------------------   
    if @I_Indicador <>''
       set @F_cadindicador ='a.indicador§'+@I_Indicador+'¶'   
    else
       set @F_cadindicador = ''  
    
    set @F_Criterio = 'x.cliente§'  +case @I_Usuario when 0 then '' 
                                    else ltrim(str(@I_Usuario))end+'¶'
                     +'x.agencia§'  +case @I_agencia when 0 then '' 
                                    else ltrim(str(@I_agencia))end+'¶'
                     +@F_cadindicador--'a.indicador§'+@I_Indicador+'¶'                                                    
    exec @F_error_exec=Construct_GLB
                       @I_mostrar    = 'N',
                       @IO_construct = @F_criterio  output,
                       @O_error_msg  = @O_error_msg output
    IF @@error <> 0 
       BEGIN
       SET @O_error_msg ='Error al ejecutar Construct_GLB.'
       GOTO Error
       END  
				IF @F_error_exec <> 0 GOTO Error    
       
    insert into #tabla_reporte    
    Select 5,8,1,Linea_texto           = ''                 
    union all select 5,8,1,Linea_texto = '-----------------------------------------------' 
    union all select 5,8,1,Linea_texto = '###   MODIFICACIÓN DE LÍMITE TEMPORAL COMPRAS INTERNET    ###'
    union all select 5,8,1,Linea_texto = '-----------------------------------------------' 
    union all select 5,8,1,Linea_texto = ' USUARIO     CÍDIGO    NOMBRE CLIENTE                       NRO. TARJETA     TIPO TARJETA     COMISIÍN     ESTADO         TRANSACCIÓN               MONTO_LÍMITE   FECHA_INI    FECHA_FIN    FECHA_HORA_MODIFICACIÓN   INDICADOR'
    
    insert into #tabla_reporte  
    exec ('select distinct 5,8,1,Linea_texto = cast(isnull (x.nombcorto,'' '') as char(8))+space(3)+ '+
                ' str(f.cliente,8)+ space(4)+'+  
                ' cast(f.nombre_ful as char(35)) + ' + '''  '' + ' +  
                --' str(a.nro_tarjeta,16) + ' + '''  '' + ' +
                ' dbo.fn_tjt_enmascTarjeta(a.nro_tarjeta, ' + @F_EnmascararTjt + ') + ' + '''  '' + ' +
		' cast((case when a.cod_tran = 265 then ' + '''TJT.ADICIONAL''' + ' else ' + '''TJT.TITULAR''' + ' end ' + ')' + ' as char(14)) + ' + '''  '' + ' +
                ' ''NO''+ space(11)+'+
                ' cast(a3.sigla as char(11))+space(5) + ' +  
                ' cast(y.descripcion as char(20))+space(4) + ' + 
                ' str(z.monto,10,2)+space(6)  + ' +
                ' (convert(char(10),z.fecha_inicio_temp,105))+space(3)+(convert(char(10),z.fecha_proceso_hasta,105)) +space(3)+' +
                ' convert(char(20),z.fecha_alta,120) +space(6)+'+
                ' ltrim(a.indicador) '   +               

             ' FROM tjttrn_tarjeta as a WITH (NOLOCK), '+
                 '  tjtmst_maestro as a1 WITH (NOLOCK), ' +
                 '  tjtmst_saldia as a2 WITH (NOLOCK), ' +
                 '  pamtjt_estado as a3 WITH (NOLOCK), ' +
                 '  climst_cliente as f WITH (NOLOCK), '+
                 '  climov_usuario as x WITH (NOLOCK), '+
                 '  pam_codtran as y WITH (NOLOCK), '+
                 '  tjtmst_detLimiteInternet as z WITH (NOLOCK) '+
           '  WHERE ' + @F_Criterio +
              ' and a.fecha_proceso = ' + @F_fecha +
              ' and a.cod_tran in (354) ' +
              ' and a.indicador = ''A'' ' +
              ' and a2.nro_tarjeta = a.nro_tarjeta ' +
              ' and a.fecha_proceso between a2.fecha_proceso and a2.fecha_proceso_hasta ' +
              ' and a.estado = 2 '+
              ' and a3.estado = a.estado ' + 
              ' and a3.indicador = ''A'' ' +
              ' and a1.nro_tarjeta = a.nro_tarjeta ' +
              ' and a1.indicador = ''A'' ' +
              
              ' and f.cliente = a1.cliente ' +
              ' and a.fecha_proceso between f.fecha_proceso and f.fecha_proceso_hasta ' +
              ' and f.indicador in (''A'',''P'') ' +
              ' and x.indicador = ''A'' ' +
              ' and x.cliente = a.usuario' +
													 ' and x.fecha_proceso_hasta = ''01-01-2050'' ' +
              ' and y.cod_tran=a.cod_tran' + 
              ' and y.sistema = 210' +
              ' and y.indicador = ''A'' ' +
              ' and y.cod_tran in (354)'+
              ' and z.nro_tarjeta=a.nro_tarjeta '+
														' and z.fecha_proceso= a.fecha_proceso '+
														' and z.fecha_alta=a.fecha_alta '+
              ' and z.tipo_limite=1 ')    
              
    insert into #tabla_reporte                     
    Select 5,8,1,Linea_texto = ''    
    
    insert into #tabla_reporte      
    exec (' SELECT 5,8,1,Linea_texto =''MODIFICACION DE LIMITE TEMPORAL COMPRAS INTERNET----->'' +SPACE(5)+ ltrim(STR(COUNT(distinct a.nro_tarjeta)))'+
             ' FROM tjttrn_tarjeta as a WITH (NOLOCK), '+
                 '  tjtmst_maestro as a1 WITH (NOLOCK), ' +
                 '  tjtmst_saldia as a2 WITH (NOLOCK), ' +
                 '  climov_usuario as x WITH (NOLOCK)'+
           '  WHERE ' + @F_Criterio +
              ' and a.fecha_proceso =' + @F_fecha +
              ' and a.cod_tran in (354) ' +
              ' and a.indicador = ''A'' ' +
              ' and a2.nro_tarjeta = a.nro_tarjeta ' +
              ' and a.fecha_proceso between a2.fecha_proceso and a2.fecha_proceso_hasta ' +
              ' and a.estado = 2 '+
              ' and a.usuario = x.cliente '+
              ' and x.indicador=''A'' '+
              ' and a.fecha_proceso between x.fecha_proceso and x.fecha_proceso_hasta '+
              ' and a1.nro_tarjeta = a.nro_tarjeta ' +
              ' and a1.indicador = ''A'' group by a.cod_tran ')
              
              
      set @RowCount=0
      select @RowCount=count(id) from #tabla_reporte where tipo =5 and subtipo=8   
           
      if @RowCount = 6--Cantidad de lineas que ocupa el header(6) y footer(2)
      begin 
            update #tabla_reporte set  visible=0 where tipo =5 and subtipo=8                  
      end       

------------------------------------             
------------------------------------------------------------------------------------------------------------------------
------ Habilitar/Deshabilitar de limite diario internet
------------------------------------------------------------------------------------------------------------------------   
    if @I_Indicador <>''
       set @F_cadindicador ='a.indicador§'+@I_Indicador+'¶'   
    else
       set @F_cadindicador = ''  
    
    set @F_Criterio = 'x.cliente§'  +case @I_Usuario when 0 then '' 
                                    else ltrim(str(@I_Usuario))end+'¶'
                     +'x.agencia§'  +case @I_agencia when 0 then '' 
                                    else ltrim(str(@I_agencia))end+'¶'
                     +@F_cadindicador--'a.indicador§'+@I_Indicador+'¶'                                                    
    exec @F_error_exec=Construct_GLB
                       @I_mostrar    = 'N',
                       @IO_construct = @F_criterio  output,
                       @O_error_msg  = @O_error_msg output
    IF @@error <> 0 
       BEGIN
       SET @O_error_msg ='Error al ejecutar Construct_GLB.'
       GOTO Error
       END  
				IF @F_error_exec <> 0 GOTO Error    
       
    insert into #tabla_reporte    
    Select 5,9,1,Linea_texto           = ''                 
    union all select 5,9,1,Linea_texto = '-----------------------------------------------' 
    union all select 5,9,1,Linea_texto = '###   HABILITAR/DESHABILITAR DE LÍMITE DIARIO COMPRAS INTERNET   ###'
    union all select 5,9,1,Linea_texto = '-----------------------------------------------' 
    union all select 5,9,1,Linea_texto = ' USUARIO     CÓDIGO    NOMBRE CLIENTE                       NRO. TARJETA     TIPO TARJETA     ESTADO         TRANSACCIÓN                         MONTO_LÍMITE   OBSERVACIÓN    FECHA_HORA_MODIFICACIÓN   '
    
    insert into #tabla_reporte  
    exec ('select distinct 5,9,1,Linea_texto = cast(isnull (x.nombcorto,'' '') as char(8))+space(3)+ '+
                ' str(f.cliente,8)+ space(4)+'+  
                ' cast(f.nombre_ful as char(35)) + ' + '''  '' + ' +  
                ' dbo.fn_tjt_enmascTarjeta(a.nro_tarjeta, ' + @F_EnmascararTjt + ') + ' + '''  '' + ' +
		' cast((case when a.cod_tran = 265 then ' + '''TJT.ADICIONAL''' + ' else ' + '''TJT.TITULAR''' + ' end ' + ')' + ' as char(14)) + ' + '''  '' + ' +
                ' cast(a3.sigla as char(11))+space(5) + ' +  
                ' cast(y.descripcion as char(30))+space(4) + ' + 
                ' str(z.monto,10,2)+space(6)  + ' +
                ' cast((case when z.indicador = ''A'' then ' + '''HABILITAR''' + ' else ' + '''DESHABILITAR''' + ' end ' + ')' + ' as char(12)) +space(3)+ ' +                         
                ' convert(char(20),z.fecha_alta,120) +space(6)'+
             ' FROM tjttrn_tarjeta as a WITH (NOLOCK), '+
                 '  tjtmst_maestro as a1 WITH (NOLOCK), ' +
                 '  pamtjt_estado as a3 WITH (NOLOCK), ' +
                 '  climst_cliente as f WITH (NOLOCK), '+
                 '  climov_usuario as x WITH (NOLOCK), '+
                 '  pam_codtran as y WITH (NOLOCK), '+
                 '  tjtmst_detLimiteInternet as z WITH (NOLOCK) '+
           '  WHERE ' + @F_Criterio +
              ' and a.fecha_proceso = ' + @F_fecha +
              ' and a.cod_tran in (355) ' +
              ' and a.indicador = ''A'' ' +
              
              ' and a.estado = 2 '+
              ' and a3.estado = a.estado ' + 
              ' and a3.indicador = ''A'' ' +
              ' and a1.nro_tarjeta = a.nro_tarjeta ' +
              ' and a1.indicador = ''A'' ' +
            
              ' and f.cliente = a1.cliente ' +
              ' and a.fecha_proceso between f.fecha_proceso and f.fecha_proceso_hasta ' +
              ' and f.indicador in (''A'',''P'') ' +
              ' and x.indicador = ''A'' ' +
              ' and x.cliente = a.usuario' +
											   ' and x.fecha_proceso_hasta = ''01-01-2050'' ' +  
              ' and y.cod_tran=a.cod_tran' + 
              ' and y.sistema = 210' +
              ' and y.indicador = ''A'' ' +
              ' and y.cod_tran in (355)'+
              ' and z.nro_tarjeta=a.nro_tarjeta '+
              ' and z.fecha_proceso= a.fecha_proceso '+
														' and z.fecha_alta=a.fecha_alta '+
              ' and z.tipo_limite=0  ')
														  
    insert into #tabla_reporte                     
    Select 5,9,1,Linea_texto = ''    
    
    insert into #tabla_reporte      
    exec (' SELECT 5,9,1,Linea_texto =''HABILITAR/DESHABILITAR DE LIMITE DIARIO COMPRAS INTERNET----->'' +SPACE(5)+ ltrim(STR(COUNT(distinct a.nro_tarjeta)))'+
             ' FROM tjttrn_tarjeta as a WITH (NOLOCK), '+
                 '  tjtmst_maestro as a1 WITH (NOLOCK), ' +
                 '  tjtmst_saldia as a2 WITH (NOLOCK), ' +
                 '  climov_usuario as x WITH (NOLOCK)'+
           '  WHERE ' + @F_Criterio +
              ' and a.fecha_proceso = ' + @F_fecha + 
              ' and a.cod_tran in (355) ' +
              ' and a.indicador = ''A'' ' +
              ' and a2.nro_tarjeta = a.nro_tarjeta ' +
              ' and a.fecha_proceso between a2.fecha_proceso and a2.fecha_proceso_hasta ' +
              ' and a.estado = 2 '+
              ' and a.usuario = x.cliente '+
              ' and x.indicador=''A'' '+
              ' and a.fecha_proceso between x.fecha_proceso and x.fecha_proceso_hasta '+
              ' and a1.nro_tarjeta = a.nro_tarjeta ' +
              ' and a1.indicador = ''A'' group by a.cod_tran ')
              
      set @RowCount=0
      select @RowCount=count(id) from #tabla_reporte where tipo =5 and subtipo=9   
           
      if @RowCount = 6--Cantidad de lineas que ocupa el header(6) y footer(2)
      begin 
            update #tabla_reporte set  visible=0 where tipo =5 and subtipo=9                  
      end       
------------------------------------------------------------------------------------------------------------------------
------ Modificacion de limite general internet
------------------------------------------------------------------------------------------------------------------------   
    if @I_Indicador <>''
       set @F_cadindicador ='a.indicador§'+@I_Indicador+'¶'   
    else
       set @F_cadindicador = ''  
    
    set @F_Criterio = 'x.cliente§'  +case @I_Usuario when 0 then '' 
                                    else ltrim(str(@I_Usuario))end+'¶'
                     +'x.agencia§'  +case @I_agencia when 0 then '' 
                                    else ltrim(str(@I_agencia))end+'¶'
                     +@F_cadindicador--'a.indicador§'+@I_Indicador+'¶'                                                    
    exec @F_error_exec=Construct_GLB
                       @I_mostrar    = 'N',
                       @IO_construct = @F_criterio  output,
                       @O_error_msg  = @O_error_msg output
    IF @@error <> 0 
       BEGIN
       SET @O_error_msg ='Error al ejecutar Construct_GLB.'
       GOTO Error
       END  
				IF @F_error_exec <> 0 GOTO Error    
       
    insert into #tabla_reporte    
    Select 5,10,1,Linea_texto           = ''                 
    union all select 5,10,1,Linea_texto = '-----------------------------------------------' 
    union all select 5,10,1,Linea_texto = '###   MODIFICACIÓN DE LÍMITE GENERAL COMPRAS INTERNET    ###'
    union all select 5,10,1,Linea_texto = '-----------------------------------------------' 
    union all select 5,10,1,Linea_texto = ' USUARIO     CÓDIGO    NOMBRE CLIENTE                       NRO. TARJETA     TIPO TARJETA     ESTADO         TRANSACCIÓN                         MONTO_LÍMITE   FECHA_HORA_MODIFICACIÓN   '
    
    insert into #tabla_reporte  
    exec ('select distinct 5,10,1,Linea_texto = cast(isnull (x.nombcorto,'' '') as char(8))+space(3)+ '+
                ' str(f.cliente,8)+ space(4)+'+  
                ' cast(f.nombre_ful as char(35)) + ' + '''  '' + ' +  
                ' dbo.fn_tjt_enmascTarjeta(a.nro_tarjeta, ' + @F_EnmascararTjt + ') + ' + '''  '' + ' +
		              ' cast((case when a.cod_tran = 265 then ' + '''TJT.ADICIONAL''' + ' else ' + '''TJT.TITULAR''' + ' end ' + ')' + ' as char(14)) + ' + '''  '' + ' +
                ' cast(a3.sigla as char(11))+space(5) + ' +  
                ' cast(y.descripcion as char(30))+space(4) + ' + 
                ' str(z.monto,10,2)+space(6)  + ' +
                ' convert(char(20),z.fecha_alta,120) +space(6)'+

             ' FROM tjttrn_tarjeta as a WITH (NOLOCK), '+
                 '  tjtmst_maestro as a1 WITH (NOLOCK), ' +
                 '  pamtjt_estado as a3 WITH (NOLOCK), ' +
                 '  climst_cliente as f WITH (NOLOCK), '+
                 '  climov_usuario as x WITH (NOLOCK), '+
                 '  pam_codtran as y WITH (NOLOCK), '+
                 '  tjtmst_detLimiteInternet as z WITH (NOLOCK) '+
           '  WHERE ' + @F_Criterio +
              ' and a.fecha_proceso = ' + @F_fecha + 
              ' and a.cod_tran in (359) ' +
              ' and a.indicador = ''A'' ' +
              ' and a.estado = 2 '+
              ' and a3.estado = a.estado ' + 
              ' and a3.indicador = ''A'' ' +
              ' and a1.nro_tarjeta = a.nro_tarjeta ' +
              ' and a1.indicador = ''A'' ' +
              ' and f.cliente = a1.cliente ' +
              ' and a.fecha_proceso between f.fecha_proceso and f.fecha_proceso_hasta ' +
              ' and f.indicador in (''A'',''P'') ' +
              ' and x.indicador = ''A'' ' +
              ' and x.cliente = a.usuario' +
              ' and a.fecha_proceso between x.fecha_proceso and x.fecha_proceso_hasta '+
              ' and y.cod_tran=a.cod_tran' + 
              ' and y.sistema = 210' +
              ' and y.indicador = ''A'' ' +
              ' and y.cod_tran in (359)'+
              ' and z.nro_tarjeta=a.nro_tarjeta '+
														' and z.fecha_proceso= a.fecha_proceso '+
														' and z.fecha_alta=a.fecha_alta '+
              ' and z.tipo_limite=0 ')    
              
    insert into #tabla_reporte                     
    Select 5,10,1,Linea_texto = ''    
    
    insert into #tabla_reporte      
    exec (' SELECT 5,10,1,Linea_texto =''MODIFICACION DE LIMITE GENERAL COMPRAS INTERNET----->'' +SPACE(5)+ ltrim(STR(COUNT(distinct a.nro_tarjeta)))'+
             ' FROM tjttrn_tarjeta as a WITH (NOLOCK), '+
                 '  tjtmst_maestro as a1 WITH (NOLOCK), ' +
                 '  climov_usuario as x WITH (NOLOCK)'+
           '  WHERE ' + @F_Criterio +
              ' and a.fecha_proceso = ' + @F_fecha +
              ' and a.cod_tran in (359) ' +
              ' and a.indicador = ''A'' ' +
              ' and a.estado = 2 '+
              ' and a.usuario = x.cliente '+
              ' and x.indicador=''A'' '+
              ' and a.fecha_proceso between x.fecha_proceso and x.fecha_proceso_hasta '+
              ' and a1.nro_tarjeta = a.nro_tarjeta ' +
              ' and a1.indicador = ''A'' group by a.cod_tran ')
              
              
      set @RowCount=0
      select @RowCount=count(id) from #tabla_reporte where tipo =5 and subtipo=10   
           
      if @RowCount = 6--Cantidad de lineas que ocupa el header(6) y footer(2)
      begin 
            update #tabla_reporte set  visible=0 where tipo =5 and subtipo=10                  
      end       

------------------------------------------------------------------------------------------------------------------------
------ Tarjeta Débito uso exterior   RD-6465
------------------------------------------------------------------------------------------------------------------------   
    if @I_Indicador <>''
       set @F_cadindicador ='a.indicador§'+@I_Indicador+'¶'   
    else
       set @F_cadindicador = ''  
    
    set @F_Criterio = 'x.cliente§'  +case @I_Usuario when 0 then '' 
                                    else ltrim(str(@I_Usuario))end+'¶'
                     +'x.agencia§'  +case @I_agencia when 0 then '' 
                                    else ltrim(str(@I_agencia))end+'¶'
                     +@F_cadindicador--'a.indicador§'+@I_Indicador+'¶'                                                    
    exec @F_error_exec=Construct_GLB
                       @I_mostrar    = 'N',
                       @IO_construct = @F_criterio  output,
                       @O_error_msg  = @O_error_msg output
    IF @@error <> 0 
       BEGIN
       SET @O_error_msg ='Error al ejecutar Construct_GLB.'
       GOTO Error
       END  
				IF @F_error_exec <> 0 GOTO Error    
       
    insert into #tabla_reporte    
    Select 5,11,1,Linea_texto           = ''                 
    union all select 5,11,1,Linea_texto = '-----------------------------------------------' 
    union all select 5,11,1,Linea_texto = '###   MODIFICACIÓN DE USO EXTERIOR  ###'
    union all select 5,11,1,Linea_texto = '-----------------------------------------------' 
    union all select 5,11,1,Linea_texto = ' USUARIO     CÓDIGO    NOMBRE CLIENTE                       NRO. TARJETA     TIPO TARJETA     TRANSACCIÓN                       FECHA_HORA_MODIFICACIÓN OBSERVACIONES                                                                   '
    
    insert into #tabla_reporte  
    exec ('select  5,11,1,Linea_texto = cast(isnull (x.nombcorto,'' '') as char(8))+space(3)+ '+
                ' str(f.cliente,8)+ space(4)+'+  
                ' cast(f.nombre_ful as char(35)) + ' + '''  '' + ' +  
                ' dbo.fn_tjt_enmascTarjeta(a.nro_tarjeta, ' + @F_EnmascararTjt + ') + ' + '''  '' + ' +
		              ' cast((case when a1.tipo_tarjeta = 2 then ' + '''TJT.ADICIONAL''' + ' else ' + '''TJT.TITULAR''' + ' end ' + ')' + ' as char(14)) + ' + '''  '' + ' +           
                ' cast(y.descripcion as char(30))+space(4) + ' +           
                ' convert(char(20),a.fecha_alta,120) +space(4)+'+                       
                ' cast(a.observaciones as char(80))+space(3)'+
             ' FROM tjttrn_tarjeta as a WITH (NOLOCK), '+
                 '  tjtmst_maestro as a1 WITH (NOLOCK), ' +
                 '  climst_cliente as f WITH (NOLOCK), '+
                 '  climov_usuario as x WITH (NOLOCK), '+
                 '  pam_codtran as y WITH (NOLOCK) '+
           '  WHERE ' + @F_Criterio +
              ' and a.fecha_proceso =' + @F_fecha + 
              ' and a.cod_tran in (248,249) ' +
              ' and a.indicador = ''A'' ' +
              ' and a.estado = 2 '+
              ' and a1.nro_tarjeta = a.nro_tarjeta ' +
              ' and a1.indicador = ''A'' ' +
              ' and f.cliente = a1.cliente ' +
              ' and a.fecha_proceso between f.fecha_proceso and f.fecha_proceso_hasta ' +
              ' and f.indicador in (''A'',''P'') ' +
              ' and x.indicador = ''A'' ' +
              ' and x.cliente = a.usuario' +
              ' and a.fecha_proceso between x.fecha_proceso and x.fecha_proceso_hasta '+
              ' and y.cod_tran=a.cod_tran' + 
              ' and y.sistema = 210' +
              ' and y.indicador = ''A'' ' 
														)    
              
    insert into #tabla_reporte                     
    Select 5,11,1,Linea_texto = ''    
    
    insert into #tabla_reporte      
    exec (' SELECT 5,11,1,Linea_texto =''MODIFICACION DE USO EXTERIOR----->'' +SPACE(5)+ ltrim(STR(COUNT(a.nro_tarjeta)))'+
             ' FROM tjttrn_tarjeta as a WITH (NOLOCK), '+
                 '  tjtmst_maestro as a1 WITH (NOLOCK), ' +               
                 '  climov_usuario as x WITH (NOLOCK)'+
           '  WHERE ' + @F_Criterio +
              ' and a.fecha_proceso = ' + @F_fecha +
              ' and a.cod_tran in (248,249) ' +
              ' and a.indicador = ''A'' ' +         
              ' and a.estado = 2 '+
              ' and a.usuario = x.cliente '+
              ' and x.indicador=''A'' '+
              ' and a.fecha_proceso between x.fecha_proceso and x.fecha_proceso_hasta '+
              ' and a1.nro_tarjeta = a.nro_tarjeta ' +
              ' and a1.indicador = ''A'' ')
              
      set @RowCount=0
      select @RowCount=count(id) from #tabla_reporte where tipo =5 and subtipo=11   
           
      if @RowCount = 6--Cantidad de lineas que ocupa el header(6) y footer(2)
      begin 
            update #tabla_reporte set  visible=0 where tipo =5 and subtipo=11                  
      end     
	  
	insert into #tabla_reporte    
		Select 5,11,1,Linea_texto           = ''                 
		union all select 5,11,1,Linea_texto = '---------------------------------------------------------------' 
		union all select 5,11,1,Linea_texto = '###   MODIFICACIÓN DE COMPRA CONTACTLESS SIN PIN NACIONAL   ###'
		union all select 5,11,1,Linea_texto = '---------------------------------------------------------------' 
		union all select 5,11,1,Linea_texto = ' USUARIO     CÓDIGO    NOMBRE CLIENTE                       NRO. TARJETA     TIPO TARJETA     TRANSACCIÓN                           MONTO TRN     MONTO DIARIO    FECHA_HORA_MODIFICACIÓN OBSERVACIONES'
    
	insert into #tabla_reporte  
		exec ('select  5,11,1,Linea_texto = cast(isnull (x.nombcorto,'' '') as char(8))+space(3)+ '+
                ' str(f.cliente,8)+ space(4)+'+  
                ' cast(f.nombre_ful as char(35)) + ' + '''  '' + ' +  
                ' dbo.fn_tjt_enmascTarjeta(a.nro_tarjeta, ' + @F_EnmascararTjt + ') + ' + '''  '' + ' +
		              ' cast((case when a1.tipo_tarjeta = 2 then ' + '''TJT.ADICIONAL''' + ' else ' + '''TJT.TITULAR''' + ' end ' + ')' + ' as char(14)) + ' + '''  '' + ' +           
                ' cast(y.descripcion as char(30))+space(4) + ' +            
				' str(z.monto_trn_sinpin_nac,13,2)+space(4)+'+
				' str(z.monto_diario_sinpin_nac,13,2)+space(4)+'+
				' convert(char(20),a.fecha_alta,120) +space(4)+'+ 
                ' cast(a.observaciones as char(80))+space(3)'+
             ' FROM tjttrn_tarjeta as a WITH (NOLOCK), '+
                 '  tjtmst_maestro as a1 WITH (NOLOCK), ' +
                 '  climst_cliente as f WITH (NOLOCK), '+
                 '  climov_usuario as x WITH (NOLOCK), '+
                 '  pam_codtran as y WITH (NOLOCK), '+
				 '  tjtmst_trnsinpin_tarjeta as z WITH (NOLOCK) '+
           '  WHERE ' + @F_Criterio +
              ' and a.fecha_proceso = ' + @F_fecha + 
              ' and a.cod_tran in (369,370) ' +
              ' and a.indicador = ''A'' ' +
              ' and a.estado = 2 '+
              ' and a1.nro_tarjeta = a.nro_tarjeta ' +
              ' and a1.indicador = ''A'' ' +
              ' and f.cliente = a1.cliente ' +
              ' and a.fecha_proceso between f.fecha_proceso and f.fecha_proceso_hasta ' +
              ' and f.indicador in (''A'',''P'') ' +
              ' and x.indicador = ''A'' ' +
              ' and x.cliente = a.usuario' +
              ' and a.fecha_proceso between x.fecha_proceso and x.fecha_proceso_hasta '+
              ' and y.cod_tran=a.cod_tran' + 
              ' and y.sistema = 210' +
			  ' and a.comprobante = z.comprobante' +
              ' and y.indicador = ''A'' ' 
														)    

    insert into #tabla_reporte                     
    Select 5,11,1,Linea_texto = ''    
    
    insert into #tabla_reporte      
    exec (' SELECT 5,11,1,Linea_texto =''MODIFICACION DE COMPRA CONTACTLESS SIN PIN NACIONAL----->'' +SPACE(5)+ ltrim(STR(COUNT(a.nro_tarjeta)))'+
             ' FROM tjttrn_tarjeta as a WITH (NOLOCK), '+
                 '  tjtmst_maestro as a1 WITH (NOLOCK), ' +               
                 '  climov_usuario as x WITH (NOLOCK), '+
				 '  tjtmst_trnsinpin_tarjeta as z WITH (NOLOCK) '+
           '  WHERE ' + @F_Criterio +
              ' and a.fecha_proceso = ' + @F_fecha +
              ' and a.cod_tran in (369,370) ' +
              ' and a.indicador = ''A'' ' +         
              ' and a.estado = 2 '+
              ' and a.usuario = x.cliente '+
              ' and x.indicador=''A'' '+
              ' and a.fecha_proceso between x.fecha_proceso and x.fecha_proceso_hasta '+
              ' and a1.nro_tarjeta = a.nro_tarjeta ' +
			  ' and a.comprobante = z.comprobante' +
              ' and a1.indicador = ''A'' ')
              
              
      set @RowCount=0
      select @RowCount=count(id) from #tabla_reporte where tipo =5 and subtipo=11   
           
      if @RowCount = 6--Cantidad de lineas que ocupa el header(6) y footer(2)
      begin 
            update #tabla_reporte set  visible=0 where tipo =5 and subtipo=11                  
      end                                 
--------------------------------------------------------------------------------------------------------------------------
------MODIFICACION DE TARJETAS
--------------------------------------------------------------------------------------------------------------------------
    
   insert into #tabla_reporte    
   Select 5,3,1,Linea_texto           = ''                 
   union all Select 5,3,1,Linea_texto = '----------------------------------------------------------------------------------------------------------------------------------' 
   union all Select 5,3,1,Linea_texto = 'MODIFICACIÓN DE CUENTAS'
   union all Select 5,3,1,Linea_texto = '----------------------------------------------------------------------------------------------------------------------------------' 
   union all Select 5,3,1,Linea_texto = '-------------------------------------------------------------------------------------------------------------------------------' 
   union all Select 5,3,1,Linea_texto = 'USUARIO       NRO DE TARJETA             NOMBRE                    CUENTA       AGREGADA   QUITADA   INDICADOR'
   union all Select 5,3,1,Linea_texto = '--------------------------------------------------------------------------------------------------------------------------------' 
   
    set @F_Criterio1 = 'e.cliente§' +case @I_Usuario when 0 then '' 
                                     else ltrim(str(@I_Usuario))end+'¶'
                      +'e.agencia§'+ case @I_agencia when 0 then '' 
                                     else ltrim(str(@I_agencia))end+'¶'
    exec @F_error_exec=Construct_GLB
                       @I_mostrar    = 'N',
                       @IO_construct = @F_Criterio1  output,
                       @O_error_msg  = @O_error_msg output
    IF @@error <> 0 
       BEGIN
       SET @O_error_msg ='Error al ejecutar Construct_GLB.'
       GOTO Error
       END  
				IF @F_error_exec <> 0 GOTO Error    
   declare @I_nro_tarjeta decimal,
           @I_nombrecliente varchar(50),
           @I_nombre_usuario varchar(25)
   insert into @tb_temporal_tjt
      EXEC( ' select distinct a.nro_tarjeta, f.nombre_ful, e.nombcorto, c.sec_alta
              from tjtmst_maestro as a WITH (NOLOCK), 
                   tjtmst_saldia  as b WITH (NOLOCK), 
                   tjtrel_cuenta  as c WITH (NOLOCK),
                   pamtjt_bin     as d WITH (NOLOCK), 
                   climov_usuario as e WITH (NOLOCK),                   
                   climst_cliente as f WITH (NOLOCK)
             where ' + @F_Criterio1 +
             ' and a.indicador=''A''
               and a.nro_tarjeta=b.nro_tarjeta
               and c.fecha_proceso= ' + @F_fecha +
             ' and b.fecha_proceso_hasta=''01-01-2050''
               and b.estado=2
               and c.fecha_proceso between b.fecha_proceso and b.fecha_proceso_hasta  
               and a.nro_tarjeta=c.nro_tarjeta
               and c.indicador = ''A''
               and substring (str(d.bin,6),1,6)=substring (a.nro_tarjeta,1,6)
               and d.indicador=''A''
               and d.fecha_proceso_hasta=''01-01-2050''
               and b.fecha_proceso_hasta=''01-01-2050''
               and c.usuario=e.cliente 
               and ( (a.fecha_solicitud=c.fecha_proceso and c.sec_index>1 ) 
                  or (c.fecha_proceso <> a.fecha_solicitud ))
               and e.indicador=''A'' 
               and c.fecha_proceso between e.fecha_proceso and e.fecha_proceso_hasta              
               and f.cliente=a.cliente
               and f.fecha_proceso_hasta=''01-01-2050''
               and f.indicador in (''A'',''P'') order by c.sec_alta,f.nombre_ful asc')

   select  @F_maxsec =max(id), @F_count=min(id) from @tb_temporal_tjt
  	select @F_count =isnull(@F_count,1),
          @F_maxsec =isnull(@F_maxsec,0)

   while (@F_count <= @F_maxsec)  
   begin
     select @I_nro_tarjeta   =nro_tarjeta   ,
            @I_nombrecliente =nombrecliente ,
            @I_nombre_usuario=nombre_usuario,
            @F_sec_alta      =sec_alta      
      	from @tb_temporal_tjt t
      where t.id = @F_count  
                           
                           IF isnull(@F_sec_alta,0)<=1
                              begin
                              
                              insert into #tabla_reporte   
                              select 5,3,1,linea_texto=cast(@I_nombre_usuario as char (8))+space(4)+str(@I_nro_tarjeta,16)+space(8)+cast(@I_nombrecliente as char(30))
                              
                              insert into #tabla_reporte 
                              exec('select distinct  5,3,1,linea_texto = space(57)+str(a.nro_cuenta,16)+space(3)+
                                             (case when(exists(select x.nro_tarjeta from tjtrel_cuenta x WITH (NOLOCK) where x.nro_tarjeta = '+ @I_nro_tarjeta+
                                                                ' and x.fecha_proceso_hasta=''01-01-2050''
                                                                  and x.nro_cuenta=a.nro_cuenta))then ''    SI         NO'' else ''    SI         SI''   end)
                                                                  + space(10)+ltrim(a.indicador)
                             from tjtrel_cuenta a WITH (NOLOCK), tjtmst_maestro b WITH (NOLOCK)  
                             where a.nro_tarjeta=b.nro_tarjeta
                                     and a.nro_tarjeta = '+@I_nro_tarjeta+
                                   ' and a.indicador=''A''
                                     and b.indicador=''A''')
                              end
                           else
                              begin
                              if @F_encabezado_rd_1781=0
                                 begin
                                 
                                 insert into #tabla_reporte
                                 Select 5,3,1,Linea_texto           ='-------------------------------------------------------------------------------------------------------------------------------' 
                                 union all select 5,3,1,linea_texto ='USUARIO       NRO DE TARJETA             NOMBRE                    CUENTA   TIEMPO    SEC-CTA  ACCIÓN'
                                 union all select 5,3,1,linea_texto ='-------------------------------------------------------------------------------------------------------------------------------' 
                                 set @F_encabezado_rd_1781=1
                                 end
                                 
                              insert into #tabla_reporte 
                              select 5,3,1,linea_texto=cast(@I_nombre_usuario as char (8))+space(4)+str(@I_nro_tarjeta,16)+space(8)+cast(@I_nombrecliente as char(30))   
                              
                              delete from @tablaTemp  
                              insert into @tablaTemp
                              exec proc_reptjt_mod_cuenta_sec_alta
                                                       @I_nro_tarjeta =@I_nro_tarjeta,
                                                       @I_sec_alta    =@F_sec_alta,
                                                       @O_error_msg   =''  
                              if @@ROWCOUNT >0
                                  begin                                        
                                        insert into #tabla_reporte                                    
                                        Select 5,3,1,linea from @tablaTemp    
                                  end                                 
                              end
                            set @F_count=@F_count+1                                  
                          END
    
    set @RowCount=0
      select @RowCount=count(id) from #tabla_reporte where tipo =5 and subtipo=3   
           
      if @RowCount = 7--Cantidad de lineas que ocupa el header(6) y footer(2)
      begin 
            update #tabla_reporte set  visible=0 where tipo =5 and subtipo=3                  
      end 
    
----  CANCELACION DE TRAJETAS 
   insert into #tabla_reporte    
   Select 5,4,1,Linea_texto           = ''                 
   union all select 5,4,1,Linea_texto = '-----------------------------------------------' 
   union all select 5,4,1,Linea_texto = '###   ESTADOS DE TARJETAS                   ###'
   union all select 5,4,1,Linea_texto = '-----------------------------------------------' 
   union all select 5,4,1,Linea_texto = ' USUARIO     CÓDIGO    NOMBRE CLIENTE                       NRO. TARJETA     TIPO TARJETA     COMISIÓN     ESTADO         OBSERVACIÓN                               INDICADOR'
   
   insert into #tabla_reporte   
   exec ('select 5,4,1,Linea_texto=cast(isnull (x.nombcorto,'' '') as char(8))+space(3)+ '+
                ' str(f.cliente,8)+ space(4)+'+  
                ' cast(f.nombre_ful as char(35)) + ' + '''  '' + ' +
                ' dbo.fn_tjt_enmascTarjeta(a.nro_tarjeta, ' + @F_EnmascararTjt + ') + ' + '''  '' + ' +
                ' cast((case when a.cod_tran = 265 then ' + '''TJT.ADICIONAL''' + ' else ' + '''TJT.TITULAR''' + ' end ' + ')' + ' as char(14)) + ' + '''  '' + ' +
                ' ''NO''+ space(11)+'+
                ' cast(a3.sigla as char(11))+space(5) + ' +  
                ' cast(a.observaciones as char(40))+space(5) +ltrim(a.indicador)' +
             ' FROM tjttrn_tarjeta as a WITH (NOLOCK), '+
                 '  tjtmst_maestro as a1 WITH (NOLOCK), ' +
                 '  tjtmst_saldia  as a2 WITH (NOLOCK), ' +
                 '  pamtjt_estado  as a3 WITH (NOLOCK), ' +
                 '  climst_cliente as f WITH (NOLOCK), '+
                 '  climov_usuario as x WITH (NOLOCK) '+
           '  WHERE ' + @F_Criterio +
              ' and a.fecha_proceso =' + @F_fecha +
              ' and a.cod_tran in (0)' +
              ' and a.indicador = ''A'' ' +
              ' and a2.nro_tarjeta = a.nro_tarjeta ' +
              ' and a.fecha_proceso between a2.fecha_proceso and a2.fecha_proceso_hasta ' +            
              ' and a.estado in(3,4,5,6,10)'+
              ' and a3.estado = a.estado ' + 
              ' and a3.indicador = ''A'' ' +
              ' and a1.nro_tarjeta = a.nro_tarjeta ' +
              ' and a1.indicador = ''A'' ' +
               ' and f.cliente = a1.cliente ' +
              ' and a.fecha_proceso between f.fecha_proceso and f.fecha_proceso_hasta ' +
              ' and f.indicador in (''A'',''P'') ' +
              ' and a.usuario=x.cliente '+
              ' and x.indicador =''A'' '+
              ' and a.fecha_proceso between x.fecha_proceso and x.fecha_proceso_hasta ' + 
              ' and a.indicador = ''A'' '+
              ' ORDER BY a.fecha_proceso')
    insert into #tabla_reporte   
    Select 5,4,1,Linea_texto = ''     
    
    insert into #tabla_reporte
    exec (' SELECT 5,4,1,LINEA_TEXTO =''ESTADOS DE TARJETAS                   ----->'' +SPACE(5)+ltrim(STR(COUNT(*)))'+
             ' FROM tjttrn_tarjeta as a WITH (NOLOCK), '+
                 '  tjtmst_maestro as a1 WITH (NOLOCK), ' +
                 '  tjtmst_saldia as a2 WITH (NOLOCK), ' +
                 '  climov_usuario as x WITH (NOLOCK)'+
           '  WHERE ' + @F_Criterio +
              ' and a.fecha_proceso = ' + @F_fecha +
              ' and a.cod_tran in (0) ' +
              ' and a.indicador = ''A'' ' +
              ' and a2.nro_tarjeta = a.nro_tarjeta ' +
              ' and a.fecha_proceso between a2.fecha_proceso and a2.fecha_proceso_hasta ' +
              ' and a.estado in(3,4,5,6,10) '+
              ' and x.indicador = ''A'' '+
              ' and a.usuario = x.cliente '+
              ' and a.fecha_proceso between x.fecha_proceso and x.fecha_proceso_hasta '+
              ' and a1.nro_tarjeta = a.nro_tarjeta ' +
              ' and a1.indicador = ''A'' ')
              
      set @RowCount=0
      select @RowCount=count(id) from #tabla_reporte where tipo =5 and subtipo=4   
           
      if @RowCount = 7--Cantidad de lineas que ocupa el header(6) y footer(2)
      begin 
            update #tabla_reporte set  visible=0 where tipo =5 and subtipo=4                  
      end          
      
-------------------------------------------------------------------------------------------------------------------------
-------DETALLE DE TARJETAS DE DEBITO
-------------------------------------------------------------------------------------------------------------------------

   insert into #tabla_reporte    
   Select 5,5,1,Linea_texto           = ''                 
   union all select 5,5,1,Linea_texto = '----------------------------------------------------------------------------------------------------------------------------------' 
   union all Select 5,5,1,Linea_texto = 'DETALLE DE TARJETA'
   union all Select 5,5,1,Linea_texto = '----------------------------------------------------------------------------------------------------------------------------------' 
   
   DECLARE @F_agencia1 varchar(5),
           @F_sql      varchar(400)
   set @F_agencia1=@I_agencia     
   set @F_sql = 'e.fecha_proceso='+@F_fecha +case @I_Usuario when 0 then '' 
                                              else ' and e.usuario='+ ltrim(str(@I_Usuario))end+
                                             case @I_agencia when 0 then ''
                                              else  ' and e.agencia='+ ltrim(str(@I_agencia))end
   
   delete from @tablaTemp  
   insert into @tablaTemp
   EXEC RepTjt_detalle_de_tarjeta_TJT  @z_fecha_proceso, 
                                       @F_sql,
                                        1,
                                       @F_agencia1                                       
   
   if @@ROWCOUNT = 6
      begin 
            update #tabla_reporte set  visible=0 where tipo =5 and subtipo=5        
      end   
  else
      begin
            insert into #tabla_reporte                                    
            Select 5,5,1,linea from @tablaTemp                                     
      end    
  
-------------------------------------------------------------------------------------------------------------------------
-------SEGURO DE PROTECCION TARJETA DEBITO
-------------------------------------------------------------------------------------------------------------------------
   if @I_Indicador <>''
      set @F_cadindicador = +'a.indicador§'+@I_Indicador+'¶'
   else
      set @F_cadindicador = ''
   set @F_Criterio = 'a.usuario_alta§' + case @I_Usuario when 0 then '' 
                                    else ltrim(str(@I_Usuario))end+'¶'
                    +'a.agencia§'+ case @I_agencia when 0 then '' 
                                    else ltrim(str(@I_agencia))end+'¶'
                    +@F_cadindicador 
   exec @F_error_exec=Construct_GLB
                       @I_mostrar    = 'N',
                       @IO_construct = @F_Criterio  output,
                       @O_error_msg  = @O_error_msg output
    IF @@error <> 0 
       BEGIN
       SET @O_error_msg ='Error al ejecutar Construct_GLB.'
       GOTO Error
       END
				IF @F_error_exec <> 0 GOTO Error    
   insert into #tabla_reporte    
   Select 5,6,1,Linea_texto           = ''                 
   union all select 5,6,1,Linea_texto = '------------------------------------------' 
   union all Select 5,6,1,Linea_texto = 'DETALLE DE SEGURO DE PROTECCIÓN DE TARJETA'
   union all Select 5,6,1,Linea_texto = '------------------------------------------' 
   union all Select 5,6,1,Linea_texto = '---------------------------------------------------------------------------------------------------------------------------------------------------' 
   union all Select 5,6,1,Linea_texto = 'Usuario   Nro_tarjta        Nombre_cliente                     TipoTarjeta Certificado   Estado       Encargado de venta'
   union all Select 5,6,1,Linea_texto = '---------------------------------------------------------------------------------------------------------------------------------------------------' 

    insert into #tabla_reporte 
   exec('select 5,6,1,Linea_texto = 
                         CAST(rtrim(c.nombcorto) as CHAR(8))+SPACE(2)+
                         dbo.fn_tjt_enmascTarjeta(a.nro_cuentaTarjeta, ' + @F_EnmascararTjt + ')+SPACE(2)+
			 --CAST(a.nro_cuentaTarjeta as CHAR(16))+SPACE(2)+
                         cast(e.nombre_ful as CHAR(35))+SPACE(2)+
                         cast(case when d.nro_tarjeta=d.nro_tarjeta_titular then ''TITULAR'' ELSE ''ADICIONAL'' end  as char(10))+space(2)+
                         cast(a.certificado as char(10))+SPACE(2)+
                         cast(f.sigla as char(10))+SPACE(2)+
                         isnull((select x.nombre_ful from climst_cliente x where x.cliente=a.gestor_venta and x.fecha_proceso_hasta=''01-01-2050'' and x.indicador=''A''),'''')
      from tjtmst_seguroProteccion a,
           pam_moneda b,
           climst_usuario c,
           tjtmst_maestro d,
           climst_cliente e,
           pam_tablas f,
           pam_agencia g,
           pam_ciudad h
     where ' + @F_criterio +
     ' and a.moneda_cuota = b.moneda
       and a.fecha_proceso = ' + @F_fecha + 
     ' and a.indicador = ''A''
       and b.indicador=''A''
       and c.cliente = a.usuario_alta
       AND c.habilitado_en_cierre = 0
       and d.nro_tarjeta = a.nro_cuentaTarjeta
       and d.indicador = ''A''
       and e.cliente = d.cliente
       and e.fecha_proceso_hasta=''01-01-2050''
       and e.indicador = ''A''
       and f.tabla = 74
       and f.codigo = a.estado
       and f.fecha_proceso_hasta=''01-01-2050''
       and f.indicador = ''A''
       and g.agencia = a.agencia
       and h.dpto = g.dpto
       and h.pais = 1
       and h.indicador = ''A''
       and a.automatico in (0,2)
     order by a.agencia, a.usuario_alta, a.estado,a.fecha_alta')

     set @RowCount=0
      select @RowCount=count(id) from #tabla_reporte where tipo =5 and subtipo=6   
           
      if @RowCount = 7--Cantidad de lineas que ocupa el header(6) y footer(2)
      begin 
            update #tabla_reporte set  visible=0 where tipo =5 and subtipo=6                  
      end          

----------------------------------------
-- Oculta titulo principal del modulo Tarjetas de Debito

 set @RowCount=0
      select @RowCount=count(id) from #tabla_reporte where tipo =5 and visible=1    
           
      if @RowCount =6--Cantidad de lineas que ocupa el header(6) y footer(2)
      begin 
            update #tabla_reporte set  visible=0 where tipo =5                  
      end   
-- endregion
-- region fono_fassil

   if @I_Indicador <>''
      set @F_cadindicador = +'a.indicador§'+@I_Indicador+'¶'
   else
      set @F_cadindicador = ''
   set @F_Criterio = 'c.cliente§' + case @I_Usuario when 0 then '' 
                                    else ltrim(str(@I_Usuario))end+'¶'
                    +'c.agencia§'+ case @I_agencia when 0 then '' 
                                    else ltrim(str(@I_agencia))end+'¶'
                    +@F_cadindicador 
   exec @F_error_exec=Construct_GLB
                       @I_mostrar    = 'N',
                       @IO_construct = @F_Criterio  output,
                       @O_error_msg  = @O_error_msg output
    IF @@error <> 0 
       BEGIN
       SET @O_error_msg ='Error al ejecutar Construct_GLB.'
       GOTO Error
       END          
				IF @F_error_exec <> 0 GOTO Error          
                      
   insert into #tabla_reporte    
   Select 6,1,1,Linea_texto           = ''  
   union all Select 6,1,1,Linea_texto = '-----------------------------------------------' 
   union all Select 6,1,1,Linea_texto = '###   MOVIMIENTO DE FONOFASSIL              ###'
   union all Select 6,1,1,Linea_texto = '-----------------------------------------------' 
   union all Select 6,1,1,Linea_texto = '---------------------------------------------------------------------------------------------------------------------------------------------------' 
   union all Select 6,1,1,Linea_texto = '  USUARIO    CÓDIGO  CLIENTE                           BENEFICIARIO                      ESTADO     TRANSACCIÓN     OBSERVACIÓN        INDICADOR   '
   union all Select 6,1,1,Linea_texto = '---------------------------------------------------------------------------------------------------------------------------------------------------' 
   
   insert into #tabla_reporte  
   Exec(' select 6,1,1,Linea_texto =  cast((select d.nombcorto from climst_usuario as d WITH (NOLOCK)
                                    where d.cliente  = a.usuario and d.indicador =''A'')as char(10))+ ' +
                                'str(a.cliente,9) +space(2)+
                                 cast(b.nombre_ful as char(30))+space(4)+
                                 cast(b.nombre_ful as char(30))+space(4)+
                                 ''APROBADA''+SPACE(5)+''APERTURA''+ space(5)+''SOLICITUD DE PIN''+space(5)+ltrim(a.indicador)'+
          'from climst_pin as a WITH (NOLOCK), ' +
              ' climst_cliente as b WITH (NOLOCK), ' +
              ' climov_usuario as c WITH (NOLOCK) '+
          ' Where ' + @F_criterio +
            ' and a.fecha_proceso between ' + @F_fecha + ' and  a.fecha_proceso_hasta ' +
            ' and a.cliente =b.cliente '+
            ' and c.indicador= ''A'' '+
            ' and a.usuario = c.cliente '+
            ' and '+ @F_fecha + ' between c.fecha_proceso and c.fecha_proceso_hasta '+
            ' and '+ @F_fecha + ' between b.fecha_proceso and b.fecha_proceso_hasta ' +
            ' and b.indicador in (''A'',''P'') '+
            ' order by a.cliente ' )
            
      set @RowCount=0
      select @RowCount=count(id) from #tabla_reporte where tipo =6 and subtipo=1   
      
      if @RowCount = 7--Cantidad de lineas que ocupa el header(6) y footer(2)
      begin 
            update #tabla_reporte set  visible=0 where tipo =6 and subtipo=1                  
      end           
            
-- end region 
-- region TRANSACCIONES

-- MOVIMIENTO DE TRANSACCIONES 
   set @F_Criterio_trn = 'u.cliente§'  +case @I_Usuario when 0 then '' 
                                    else ltrim(str(@I_Usuario))end+'¶'
                        +'u.agencia§'  +case @I_agencia when 0 then '' 
                                    else ltrim(str(@I_agencia))end+'¶'
    exec @F_error_exec=Construct_GLB
                       @I_mostrar    = 'N',
                       @IO_construct = @F_criterio_trn  output,
                       @O_error_msg  = @O_error_msg output
    IF @@error <> 0 
       BEGIN
       SET @O_error_msg ='Error al ejecutar Construct_GLB.'
       GOTO Error
       END  
				IF @F_error_exec <> 0 GOTO Error    
       
   insert into #tabla_reporte    
   Select 6,2,1,Linea_texto           = '' 
   union all Select 6,2,1,Linea_texto = '----------------------------------------------------------------------------------------------------------------------------------' 
   union all Select 6,2,1,Linea_texto = 'MOVIMIENTOS DE TRANSACCIONES'
   union all Select 6,2,1,Linea_texto = '----------------------------------------------------------------------------------------------------------------------------------'    
   union all select 6,2,1,Linea_texto = '----------------------------------------------------------------------------------------------------------------------------------------------'
   union all select 6,2,1,Linea_texto = 'USUARIO     COMPROBANTE  CODCLI  CONCEPTO                        MONTOTRAN  MDA         CARGOS     ITF      CUENTA/LINEA  PROC.CAJA  INDICADOR   '
   union all select 6,2,1,Linea_texto = '----------------------------------------------------------------------------------------------------------------------------------------------'
      
   
   delete from @tablaTempTrans  
   insert into @tablaTempTrans
   EXEC rep_Movimiento_transacciones_TRN @z_fecha_proceso, 
                                         @z_fecha_proceso,
                                         @F_criterio_trn,
                                         @I_Indicador
                                         
   --SET @O_error_msg ='@RowCount: '+ str(@@ROWCOUNT)
   --   GOTO Error
   if @@ROWCOUNT = 0

     begin 
            update #tabla_reporte set  visible=0 where tipo =6 and subtipo=2        
      end   
  else
      begin
            insert into #tabla_reporte                                    
            Select 6,2,1,linea from @tablaTempTrans                                     
      end                                       
 -- end region
-- region mov_fassilnet
-- MOVIMIENTOS DE FASSILNET
    select @F_fecha_corte_fslnet = cast(sigla as smalldatetime)
    from pam_tablas 
    where tabla = 479
      and codigo = 1 --- fecha de Corte 
      and indicador = 'A'
      and fecha_proceso_hasta = '01-01-2050'   
   
      set @F_nombcorto1 = ''
      If @I_usuario > 0
         begin
         select @F_nombcorto1   = email
           from climst_datoslocales
          where cliente = @I_usuario
            and fecha_proceso_hasta = '01-01-2050'
            and indicador ='A'
         set @F_rowcount=@@rowcount 
         IF @@error <> 0 
         or @F_rowcount=0
            BEGIN
            SET @O_error_msg ='Usuario no existe, Verifique...' 
            GOTO Error
            END               
         end

      set @F_Criterio_trn = 'h.agencia§'  +case @I_agencia when 0 then '' 
                                            else ltrim(str(@I_agencia))end+'¶'
      exec @F_error_exec=Construct_GLB
                          @I_mostrar    = 'N',
                          @IO_construct = @F_criterio_trn  output,
                          @O_error_msg  = @O_error_msg output
      IF @@error <> 0 
         BEGIN
         SET @O_error_msg ='Error al ejecutar Construct_GLB.'
         GOTO Error
         END  
				IF @F_error_exec <> 0 GOTO Error    
                          
      insert into #tabla_reporte    
      Select 7,1,1,Linea_texto           = '' 
      union all Select 7,1,1,Linea_texto = '----------------------------------------------------------------------------------------------------------------------------------' 
      union all Select 7,1,1,Linea_texto = 'MOVIMIENTOS DE SOLICITUDES DE FASSILNET'
      union all Select 7,1,1,Linea_texto = '----------------------------------------------------------------------------------------------------------------------------------'            
       --/* Quitar para Produccion - FVG
							
      if exists(select servidor 
                from pam_configuracion 
               where fecha_proceso_hasta ='01-01-2050' 
                 and indicador           ='A' 
                 and servidor            =@@SERVERNAME)
          begin               
          delete from @tablaTemp
          insert into @tablaTemp
          EXEC Rep_DetalleFassilnet 
                   @I_fecha_desde = @z_fecha_proceso,  
                   @I_fecha_hasta = @z_fecha_proceso,
                   @I_origen      = 1, -- 1 = Solictudes  
                   @F_nomb_corto  = @F_nombcorto1,
                   @I_es_subreporte = 1,
                   @I_usuario     = @I_usuario,
                   @P_condicion   = @F_criterio_trn 
          end     
      select @RowCount=count(id) from @tablaTemp     
      if @ROWCOUNT = 3
          begin 
          update #tabla_reporte set visible=0 where tipo =7 and subtipo=1        
          end   
      else
          begin
          insert into #tabla_reporte                                    
          Select 7,1,1,linea from @tablaTemp                 
          end 
  -- */
 
    set @F_Criterio_trn = 'c.agencia§'  + case @I_agencia when 0 then '' 
                                          else ltrim(str(@I_agencia))end+'¶'
    exec @F_error_exec=Construct_GLB
                       @I_mostrar    = 'N',
                       @IO_construct = @F_criterio_trn  output,
                       @O_error_msg  = @O_error_msg output
    IF @@error <> 0 
       BEGIN
       SET @O_error_msg ='Error al ejecutar Construct_GLB.'
       GOTO Error
       END  
				IF @F_error_exec <> 0 GOTO Error    
            
   insert into #tabla_reporte    
   Select 7,2,1,Linea_texto           = ''    
   if @z_fecha_proceso < @F_fecha_corte_fslnet 
      begin
      insert into #tabla_reporte
                Select 7,2,1,Linea_texto = '----------------------------------------------------------------------------------------------------------------------------------' 
      union all Select 7,2,1,Linea_texto = 'MOVIMIENTOS ADMINISTRATIVOS FASSILNET'
      union all Select 7,2,1,Linea_texto = '----------------------------------------------------------------------------------------------------------------------------------'       
      end
    else 
      begin
      insert into #tabla_reporte
                Select 7,2,1,Linea_texto = '----------------------------------------------------------------------------------------------------------------------------------' 
      union all Select 7,2,1,Linea_texto = 'SOLICITUDES DE SERVICIO FASSILNET'
      union all Select 7,2,1,Linea_texto = '----------------------------------------------------------------------------------------------------------------------------------'       
      end

   --/* Quitar para Produccion - FVG
   if exists(select servidor 
               from pam_configuracion 
              where fecha_proceso_hasta ='01-01-2050' 
                and indicador           ='A' 
                and servidor            =@@SERVERNAME)
      begin
 
   delete from @tablaTemp  
   insert into @tablaTemp  
   EXEC Rep_DetalleFassilnet   @I_fecha_desde = @z_fecha_proceso, 
                               @I_fecha_hasta = @z_fecha_proceso,
                               @I_origen      = 2, -- 2= Mov.Administrativos
                               @F_nomb_corto  = @F_nombcorto1,
                               @I_es_subreporte = 1,
                               @I_usuario     = @I_usuario,
                               @P_condicion   = @F_criterio_trn 
      end

    set @RowCount=0
    select @RowCount=count(id) from @tablaTemp 
   if @ROWCOUNT = 3
      begin 
            update #tabla_reporte set  visible=0 where tipo =7 and subtipo = 2        
      end   
  else
      begin
            insert into #tabla_reporte                                    
            Select 7,2,1,linea from @tablaTemp                                     
      end                      
   ------------------------------------------------------------------------------------------------------------------------------------     */     
      insert into #tabla_reporte    
      Select 7,3,1,Linea_texto           = '' 
      union all Select 7,3,1,Linea_texto = '----------------------------------------------------------------------------------------------------------------------------------' 
      union all Select 7,3,1,Linea_texto = 'SOLICITUDES DE SERVICIO FASSILNET - ENTREGA DE TOKEN FÍSICO AL CLIENTE '
      union all Select 7,3,1,Linea_texto = '----------------------------------------------------------------------------------------------------------------------------------'            
      set @F_Criterio_trn = 'e.cliente§'  +case @I_Usuario when 0 then '' 
                                       else ltrim(str(@I_Usuario))end+'¶'
                           +'e.agencia§'  +case @I_agencia when 0 then '' 
                                       else ltrim(str(@I_agencia))end+'¶'
       exec @F_error_exec=Construct_GLB
                          @I_mostrar    = 'N',
                          @IO_construct = @F_criterio_trn  output,
                          @O_error_msg  = @O_error_msg output
       IF @@error <> 0 
          BEGIN
          SET @O_error_msg ='Error al ejecutar Construct_GLB.'
          GOTO Error
          END  
				IF @F_error_exec <> 0 GOTO Error    

       delete from @tablaTemp  
       insert into @tablaTemp  
       EXEC proc_repfslnet_EntregaToken   @I_fecha_desde = @z_fecha_proceso, 
                                          @I_fecha_hasta = @z_fecha_proceso,
                                          @P_condicion   = @F_criterio_trn 
       set @RowCount=0
       select @RowCount=count(id) from @tablaTemp 
       if @ROWCOUNT = 3
          begin 
                update #tabla_reporte set  visible=0 where tipo =7 and subtipo = 3        
          end   
       else
          begin
                insert into #tabla_reporte                                    
                Select 7,3,1,linea from @tablaTemp                                     
          end
     
-- endregion 
-- region documentos_pago
        
   ------------------------------------------------------------------------------------------------------------------------------------     */     
   insert into #tabla_reporte    
   Select 7,4,1,Linea_texto           = '' 
   union all Select 7,4,1,Linea_texto = '-----------------------------------------------' 
   union all Select 7,4,1,Linea_texto = '###   CERTIFICACIÓN DE DOCUMENTOS DE PAGO   ###'
   union all Select 7,4,1,Linea_texto = '-----------------------------------------------' 
   union all Select 7,4,1,Linea_texto = '----------------------------------------------------------------------------------------------------------------------------------------' 
   union all Select 7,4,1,Linea_texto = '                                                                                  TIPO DE TRANSACCIÓN             N°CORRELATIVO  '
   union all Select 7,4,1,Linea_texto = ' USUARIO COMPROBANTE     SOLICITANTE     CI/NIT        CERTIFICADA        DE TRANS.        COMISIÓN  ESTADO'
   union all Select 7,4,1,Linea_texto = '----------------------------------------------------------------------------------------------------------------------------------------'                               
   if @I_Indicador <>''
      set @F_cadindicador = +'a.indicador§'+@I_Indicador+'¶'
   else
      set @F_cadindicador = ''
    
       set @F_Condicion_doc = 'c.agencia§'  +case @I_agencia when 0 then '' 
                                            else ltrim(str(@I_agencia))end+'¶'
                             +'c.cliente§'  +case @I_Usuario when 0 then '' 
                                            else ltrim(str(@I_Usuario))end+'¶'  
                             +@F_cadindicador                                                                                         
    exec @F_error_exec=Construct_GLB
                       @I_mostrar    = 'N',
                       @IO_construct = @F_Condicion_doc  output,
                       @O_error_msg  = @O_error_msg output
    IF @@error <> 0 
       BEGIN
       SET @O_error_msg ='Error al ejecutar Construct_GLB.'
       GOTO Error
       END    
				IF @F_error_exec <> 0 GOTO Error       
       
     insert into #tabla_reporte  
     Exec(' select 7,4,1,Linea_texto =  cast(c.nombcorto as char(10))+ space(2)+' +
                                 'ltrim(cast(a.comprobante_via as char(13)))+space(9)+'+ 
                                 'cast( isnull((select nombre_ful from climst_cliente where cliente = a.cliente and indicador in (''A'',''P'') and fecha_proceso_hasta= ''01-01-2050''
                                               union 
                                               select nombre_ful from climst_eventual where cliente = a.cliente and indicador = ''A''),'''' ) as char(30))+space(1)+'+
                                 'cast(isnull((select identificacion from climst_cliente where cliente = a.cliente and indicador in (''A'',''P'') and fecha_proceso_hasta= ''01-01-2050''
                                               union 
                                               select identificacion from climst_eventual where cliente = a.cliente and indicador = ''A''),'''') as char(10))+'+
                                 '(case when (isnull((select nit from climst_cliente where cliente = a.cliente and indicador in (''A'',''P'') and fecha_proceso_hasta= ''01-01-2050''),'''')) <> '''' then ''/'' else '''' end) +'+
                                 'cast(isnull((select nit from climst_cliente where cliente = a.cliente and indicador in (''A'',''P'') and fecha_proceso_hasta= ''01-01-2050''),'''') as char(10))+space(1)+'+                      
                                 'cast((case when a.sistema_via = 30 then ''Depósito en cuenta'' 
                                             when a.cod_tran = 287 then ''Transferencias electrónicas ''
                                             when a.cod_tran = 951 then ''Recepción por gestión giros enviados''
                                             else ''Traspaso entre cuentas del mismo Fondo'' end)  as char(28))+space(1)+'+                           
                                 'str(a.documento,12)+'+                                               
                                 'str((case when a.efectivo = 0 then (case when a.importe_cah= 0 then a.importe_cct else a.importe_cah end) else a.efectivo end),13,2)+space(1)+'+
                                 '(select case when moneda = 1 then ''Bs'' else ''Usd.'' end from pamtrn_concepto where concepto = 223 and indicador = ''A'') +space(3)+'+
                                 'cast(a.indicador as char(4))'+
                           ' from trnmst_documentoPago as a, '+                                
                                ' climov_usuario as c '+
                          'where '+@F_Condicion_doc+                           
                           ' and a.fecha_proceso = '+@F_fecha+                           
                           ' and c.indicador = ''A'' '+
                           ' and a.usuario = c.cliente '+
                           ' and a.fecha_proceso between c.fecha_proceso and c.fecha_proceso_hasta ')   


      set @RowCount=0
      select @RowCount=count(id) from #tabla_reporte where tipo =7 and subtipo=4   
      
      if @RowCount = 8--Cantidad de lineas que ocupa el header(6) y footer(2)
      begin 
            update #tabla_reporte set  visible=0 where tipo =7 and subtipo=4                  
      end   

-- endregion  
-- region ach

----------------------------------------------------------------------------------------------------
----  MOVIMIENTOS DE ACH
-----------------------------------------------------------------------------------------------------     
    set @F_Criterio = 'b.cliente§' +case @I_Usuario when 0 then '' 
                                    else ltrim(str(@I_Usuario))end+'¶'
                     +'b.agencia§'+ case @I_agencia when 0 then '' 
                                      else ltrim(str(@I_agencia))end+'¶'
                    -- +@F_cadindicador -- 'a.indicador§'+@I_Indicador+'¶'                                                  
    exec @F_error_exec=Construct_GLB
                       @I_mostrar    = 'N',
                       @IO_construct = @F_criterio  output,
                       @O_error_msg  = @O_error_msg output
    IF @@error <> 0 
       BEGIN
       SET @O_error_msg ='Error al ejecutar Construct_GLB.'
       GOTO Error
       END  
				IF @F_error_exec <> 0 GOTO Error     

    if @I_Indicador<> ''
       begin
       if @I_Indicador = 'R'
          set @F_criterio=ltrim(rtrim(@F_criterio))+' AND ((a.codError <> ''000'' or a.codRespuesta NOT IN (''000'',''0000'')) or a.estado in (9,10))'
       else 
          set @F_criterio=ltrim(rtrim(@F_criterio))+' AND ((a.codError = ''000'' or a.codError is null) AND (a.codRespuesta IN (''000'',''0000'') or a.codRespuesta is null) and a.estado not in (9,10))'
       end
    else
       set @F_cadindicador = ''      



   insert into #tabla_reporte    
   Select 7,5,1,Linea_texto           = '' 
   union all Select 7,5,1,Linea_texto = '----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------' 
   union all Select 7,5,1,Linea_texto = 'MOVIMIENTOS DE TRANSFERENCIAS ACH'
   union all Select 7,5,1,Linea_texto = 'LISTADO DE ENVÍO POR ACH'
   union all Select 7,5,1,Linea_texto = '----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------' 
   union all Select 7,5,1,Linea_texto = '                            Cliente                       Cuenta de                 Banco        Cuenta                                       Estado de             Estado de' 
   union all Select 7,5,1,Linea_texto = 'Usuario     Comprobante     Solicitante      CI/NIT       Débito         Comisión   Destino      Destino              Monto       Moneda      Solicitud             Envío' 
   union all Select 7,5,1,Linea_texto = '----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------' 

   insert into @tb_temporal_ach
   exec( ' select a.cod_sub_destinatario, a.cod_destinatario, a.producto_origen, a.comprobante, 
                  a.cliente_origen, a.cuenta_origen, a.cuenta_destino, a.importe, comision,
                  a.cod_moneda, a.estado, a.usuario_alta, a.codError,a.codRespuesta,
                  a.ci_nit_originante
             from achtrn_trans as a WITH (NOLOCK),
                  climov_usuario as b WITH (NOLOCK)
            where a.fecha_proceso= '+ @F_fecha +
             'and '+ @F_Criterio+
             'and b.indicador= ''A'' '+
             'and a.usuario_alta = b.cliente '+
             'and a.fecha_proceso between b.fecha_proceso and b.fecha_proceso_hasta ')
   select  @F_maxsec =max(id), @F_count=min(id) from @tb_temporal_ach
  	select @F_count =isnull(@F_count,1),
          @F_maxsec =isnull(@F_maxsec,0),
          @F_comprobante_aux = 0,
          @F_Total_Comp      = 0
  	while (@F_count <= @F_maxsec)  

      Begin
         	 select @F_sub_banco_dest = sub_banco_dest ,
                  @F_banco_dest     = banco_dest     ,
                  @F_tipo_cuenta    = tipo_cuenta    ,
                  @F_comprobante    = comprobante    ,
                  @F_cliente        = cliente        ,
                  @F_nro_cuenta_orig= nro_cuenta_orig,
                  @F_nro_cuenta_dest= nro_cuenta_dest,
                  @F_Saldo          = Saldo          ,
                  @F_comision       = comision       ,
                  @F_moneda         = moneda         ,
                  @F_estado         = estado         ,
                  @F_usuario        = usuario        ,
                  @F_codError       = codError       ,
                  @F_codRespuesta   = codRespuesta   ,
                  @F_ci_nit         = ci_nit             
            	from @tb_temporal_ach t
            where t.id = @F_count 
          if @f_tipo_cuenta = 100
             select @F_Cod_Tran = cod_tran from ccttrn_trans
              where comprobante=@F_comprobante
                and sec = 0

          if @f_tipo_cuenta = 200
             begin
             if @F_tipo_lectura=0
                select @F_Cod_Tran = cod_tran
                  from cahtrn_trans
                 where comprobante=@F_comprobante
                   and sec = 0
             else
                select @F_Cod_Tran = cod_tran
                  from histfassil.dbo.cahtrn_trans
                 where comprobante=@F_comprobante
                   and sec = 0
             end
             
          if @f_tipo_cuenta = 30
             select @F_Cod_Tran = cod_tran
               from cajhed_caja
              where comprobante=@F_comprobante
               
          select @F_nombcorto = nombcorto from climst_usuario  WITH (NOLOCK)
           where cliente = @F_usuario
             and indicador ='A'
          select @F_descripcion = descripcion from pam_codtran WITH (NOLOCK)
            where sistema =@f_tipo_cuenta
              and cod_tran= @F_cod_tran 
              and indicador='A'
          select @F_moneda = isnull(sigla,'') from pam_moneda WITH (NOLOCK)
            where moneda = cast(@F_moneda as tinyint)
              and indicador='A'

          select @f_monto_conver    = 0,
                 @F_comprobante_via = ISNULL(@F_comprobante_via,0),
                 @F_estado = ISNULL(@F_estado,0),
                 @F_Cod_Tran = ISNULL(@F_cod_tran,0)
             set @F_Total_Comp = @F_Total_Comp + 1
          
          if len(isnull(@f_nro_cuenta_orig,'')) = 0
             begin
             set @f_nro_cuenta_orig = cast(@F_comprobante_via as CHAR(25))
             set @F_comprobante_via = 0
             end
          insert into #tabla_reporte     
          select 7,5,1,linea_texto = cast(isnull(@F_nombcorto,'') as char(10))+space(2)+
                                     replace(str(isnull(@F_comprobante,0),12),' ',0 )+space(4)+ 
                                     str(isnull (@F_cliente,0),10)+space(4)+
                                     CAST(isnull(@f_ci_nit,'') as CHAR(15))+SPACE(3)+
                                     cast(isnull(@f_nro_cuenta_orig,'') as CHAR(12))+space(3)+
                                     str(isnull(@f_comision,0),8,2)+space(3)+
                                     CAST(ISNULL(dbo.fn_cli_RecuperaEntidadACH (@F_sub_banco_dest, @F_banco_dest, @F_Fecha_proceso, 2),'')as CHAR(10))+SPACE(3)+
                                     cast(isnull(@f_nro_cuenta_dest,'') as CHAR(15))+SPACE(2)+
                                     str(isnull(@F_Saldo,0),13,2)+space(5)+
                                     isnull(@F_moneda,'$')+space(7)+ 
                                     cast(isnull((select descripcion from pamach_estado where estado=@F_estado
                                                     and fecha_proceso_hasta='01-01-2050' and indicador='A' ),'') as CHAR(20))+SPACE(2)+
                                     cast(isnull((dbo.fn_cli_recuperarEstadoACH (@F_estado, @f_codError, @f_codRespuesta,0)),'') as char(10))
        set @f_count=@f_count+1
      End    
      insert into #tabla_reporte  
      select 7,5,1,linea_Texto =''
      union all select 7,5,1,linea_texto = space(10)+'TOTAL OPERACIONES ===> '+str(@F_Total_Comp,5)           

      set @RowCount=0
      select @RowCount=count(id) from #tabla_reporte where tipo =7 and subtipo=5   
      
      if @RowCount = 10--Cantidad de lineas que ocupa el header(8) y footer(2)
         update #tabla_reporte set  visible=0 where tipo =7 and subtipo=5                  
-- endregion 
-- region depositos_numerados

----------------------------------------------------------------------------------------------------
----  RD-2278 (BVC) AFILIACIONES AL SERVICIO DEPÓSITOS NUMERADOS.
----------------------------------------------------------------------------------------------------
  insert into #tabla_reporte    
  Select 7,6,1,Linea_texto           = '' 
  union all Select 7,6,1,Linea_texto = '---------------------------------------------------------------------------------------------------------------------'
  union all select 7,6,1,Linea_texto = '###     AFILIACIONES AL SERVICIO DEPÓSITOS NUMERADOS     ###'
  union all select 7,6,1,Linea_texto = '---------------------------------------------------------------------------------------------------------------------'
  union all select 7,6,1,Linea_texto = 'EMPRESA           NOMBRE                                FECHA AFIL.  NRO CUENTA   PRODUCTO  COMISIÓN  USUARIO  ESTADO'
  union all select 7,6,1,Linea_texto = '---------------------------------------------------------------------------------------------------------------------'
  
  declare @F_afiliaciones int = 0
  declare @F_tbl_estados table (sistema     smallint, --- 
                                nro_cuenta  int     ,
                                sec         smallint)

  declare @F_tbl_cliente table (sistema     smallint,
                                nro_cuenta  int ,
                                cliente     int ,
                                nombre      varchar(100))

  --- CARGAMOS CON LAS SECUENCIAS MAXIMAS 
  insert into @F_tbl_estados
  select sistema, nro_cuenta, max(sec) from climst_depNume_afiliacion
   where ((@I_Usuario> 0 and usuario = @I_Usuario ) or @I_Usuario = 0)
     and ((@I_agencia>0 and agencia= @I_agencia) or @I_agencia=0 )
     and @z_fecha_proceso = fecha_proceso
   group by sistema, nro_cuenta
  
  --- CARGAMOS LOS NOMBRES DE CLIENTES
  insert into @F_tbl_cliente
  select a.sistema, o.nro_cuenta, o.cliente, c.nombre_ful
    from @F_tbl_estados a
   inner join climst_clioper o
      on  a.sistema    = o.sistema 
     and a.nro_cuenta = o.nro_cuenta
     and o.sec        = 1  --- Modificado para obtener solo el cliente Titular
     and o.tipo_rel   = 4
   inner join climst_cliente c
      on  o.cliente = c.cliente
     and c.indicador = 'A'
     and c.fecha_proceso_hasta = '01-01-2050'
  
  --select * from climst_depNume_afiliacion
  insert into #tabla_reporte    
  select 7,6,1,linea_texto = cast(a.cod_empresa as char(15))+space(3)+cast(c.nombre as char(35))+space(3)+convert(char(10),a.fecha_proceso, 103)+space(3) + 
                       str(a.nro_cuenta,10)+space(5)+cast(s.sigla as char(5))+space(3)+str(a.comision,8,2)+space(2) +u.nombcorto + space(3) + a.indicador
    from climst_depNume_afiliacion a
   inner join @F_tbl_estados e
      on  a.sistema = e.sistema
     and a.nro_cuenta = e.nro_cuenta
     and a.sec = e.sec
   --and a.fecha_proceso between @I_fecha_desde and @I_fecha_hasta
   inner join @F_tbl_cliente c
      on  e.sistema    = c.sistema
     and e.nro_cuenta = c.nro_cuenta
     and a.sistema    = c.sistema
     and a.nro_cuenta = c.nro_cuenta
   inner join pam_sistema s
      on a.sistema = s.sistema
     and s.indicador = 'A'
   inner join climst_usuario u
      on a.usuario = u.cliente
     and u.indicador = 'A'
   --where ((len(@I_indicador)>0 and a.indicador = (case @I_indicador when 'R' then 'N' else 'A' end ) ) or len(@I_indicador)='' )--LC
  
  select @F_afiliaciones = @@rowcount
  set @F_afiliaciones = isnull(@F_afiliaciones,0)
  
  insert into #tabla_reporte   
  select 7,6,1,linea_texto = ''
  union all select 7,6,1,linea_texto = '          TOTAL AFILIACIONES ===>'+str(@F_afiliaciones)
  
  
      set @RowCount=0
      select @RowCount=count(id) from #tabla_reporte where tipo =7 and subtipo=6   
      
      if @RowCount = 8--Cantidad de lineas que ocupa el header(6) y footer(2)
      begin 
            update #tabla_reporte set  visible=0 where tipo =7 and subtipo=6                  
      end
  
  
-- endregion  
----------------------------------------------------------------------------------------------------
----  FIN RD-2278 (BVC)
----------------------------------------------------------------------------------------------------
-- region movimiento_planillas

----------------------------------------------------------------------------------------------------
----  RD-2899 (BVC) - 3.- Se solicita que en el reporte de Movimiento de captaciones se evidencie el
----                      débito realizado de la cuenta origen para el pago de planillas.
----------------------------------------------------------------------------------------------------
  declare @F_tbl_planillas table (
       usuario     int              not null,
       cliente     int              not null,
       comprobante decimal(12,0)    not null,
       cod_tran     smallint        not null,
       nro_cuenta  int              not null,
       monto_aplicado decimal(13,2) not null,
       indicador      char(1)       not null
  )
  declare @F_tbl_cuenta_sistema_planillas table(
    ccliente    int      not null,
    csistema    smallint not null,
    cnro_cuenta int      not null,
    cmoneda     tinyint  not null
  )
  declare @F_cant_pagos int = 0
  ---- Recuperamos las planillas.
  insert into @F_tbl_planillas
  select distinct p.usuario, c.cliente, p.comprobante, p.cod_tran, h.nro_cuenta, p.Monto_aplicado, h.indicador 
  from plamst_head h
  inner join convmst_convenio c
  on h.convenio = c.convenio
  and h.indicador = 'A'
  and c.indicador = 'A'
  and h.fecha_proceso_hasta ='01-01-2050'
  and c.fecha_proceso_hasta ='01-01-2050'
  inner join platrn_pagos_planillas p
  on p.convenio = c.convenio
  and p.nombre_planilla = h.nombre_planilla
  and p.fecha_proceso   = @z_fecha_proceso
  --and p.indicador       = case @I_Indicador when 'A' then 'A' when '' then 'A' else 'N' end --LC
  and p.Monto_aplicado> 0
  and ((@I_Usuario>0 and p.usuario =@I_Usuario)or(@I_Usuario=0))
  and ((@I_agencia>0 and p.agencia =@I_agencia)or(@I_agencia=0))
  
  --- Recuperamos las el sistema y la cuenta de las planillas CCT
  insert into @F_tbl_cuenta_sistema_planillas
  select distinct c.cliente, c.sistema, p.nro_cuenta, cc.moneda from @F_tbl_planillas p
  inner join climst_clioper c
  on  p.cliente    = c.cliente
  and p.nro_cuenta = c.nro_cuenta
  and c.sistema    = 100 
  and c.sec = 1
  and c.fecha_proceso_hasta = '01-01-2050'
  inner join cctmst_maestro cc
  on  c.cliente   = cc.cliente
  and c.nro_cuenta= cc.nro_cuenta
  and cc.fecha_proceso_hasta = '01-01-2050'
  
  --- Recuperamos las el sistema y la cuenta de las planillas CAH
  insert into @F_tbl_cuenta_sistema_planillas
  select distinct c.cliente, c.sistema, p.nro_cuenta, ca.moneda from @F_tbl_planillas p
  inner join climst_clioper c
  on  p.cliente    = c.cliente
  and p.nro_cuenta = c.nro_cuenta
  and c.sistema    = 200 
  and c.sec = 1
  and c.fecha_proceso_hasta = '01-01-2050'
  inner join cahmst_maestro ca
  on  c.nro_cuenta= ca.nro_cuenta
  and ca.indicador = 'A'
  
  
  
  insert into #tabla_reporte    
  Select 7,7,1,Linea_texto           = '' 
  union all Select 7,7,1,Linea_texto = '---------------------------------------------------------------------------------------------------------------------'
  union all select 7,7,1,Linea_texto = '###     DÉBITO A CONVENIOS POR PAGO DE PLANILLAS     ###'
  union all select 7,7,1,Linea_texto = '---------------------------------------------------------------------------------------------------------------------------------------------'
  union all select 7,7,1,Linea_texto = 'USUARIO               COMPROBANTE        CLIENTE     CI/NIT    COD   TRANSACCIÓN          CUENTA          MONTO  MONEDA  PROC.CAJA    ESTADO'
  union all select 7,7,1,Linea_texto = '---------------------------------------------------------------------------------------------------------------------------------------------'
  
  insert into #tabla_reporte 
  select distinct 7,7,1,Linea_texto = cast(u.nombcorto as char(20))  +space(1)+ str(p.comprobante,12)  +space(4)+str(p.cliente, 10)    +space(2)+ 
                       cast(isnull( case c.nit when '0' then c.identificacion else c.nit end,'0') as char(12))  +space(1)+ 
                       str(p.cod_tran,4)         +space(3)+cast(t.sigla as char(16))              +space(1)+ 
                       str(p.nro_cuenta,10) +space(2)+ str(p.monto_aplicado,13,2)+space(4)+substring('BS.USD',(s.cmoneda-1)*3+1,3)+space(8)+
                       cast('NA' as char(9))+space(1)+ p.indicador from @F_tbl_planillas p
  inner join @F_tbl_cuenta_sistema_planillas s
  on  p.cliente   = s.ccliente
  and p.nro_cuenta= s.cnro_cuenta
  inner join  pam_codtran t
  on  p.cod_tran = t.cod_tran
  and t.indicador = 'A'
  inner join climst_cliente c
  on  p.cliente   = c.cliente
  and c.indicador = 'A'
  and c.fecha_proceso_hasta='01-01-2050'
  inner join climst_usuario u
  on  p.usuario = u.cliente
  and u.indicador = 'A'
  
  select @F_cant_pagos=@@rowcount
  
  insert into #tabla_reporte
  select 7,7,1,linea_texto = ''
  union all select 7,7,1,linea_texto = '          TOTAL OPERACIONES ===>     '+ str(@F_cant_pagos) 

      set @RowCount=0
      select @RowCount=count(id) from #tabla_reporte where tipo =7 and subtipo=7   
      
      if @RowCount = 8--Cantidad de lineas que ocupa el header(6) y footer(2)
      begin 
            update #tabla_reporte set  visible=0 where tipo =7 and subtipo=7                  
      end
  

-- endregion    
----------------------------------------------------------------------------------------------------
----  FIN RD-2899 (BVC)
----------------------------------------------------------------------------------------------------
-- region comex

----------------------------------------------------------------------------------------------------
----  MOVIMIENTOS DE COMEX (COMERCIO EXTERIOR)
----------------------------------------------------------------------------------------------------
-- VARIABLES PARA EL SISTEMA COMEX     
declare @F_monto_cja     decimal(13,2)= 0,
        @F_monto_cah     decimal(13,2)= 0,
        @F_monto_cct     decimal(13,2)= 0,
        @F_monto_cbl     decimal(13,2)= 0,
        @F_monto_chq     decimal(13,2)= 0,
        @F_monto_chge    decimal(13,2)= 0,
        @F_total_cja     decimal(13,2)= 0,
        @F_total_cah     decimal(13,2)= 0,
        @F_total_cct     decimal(13,2)= 0,
        @F_total_cbl     decimal(13,2)= 0,
        @F_total_chq     decimal(13,2)= 0,
        @F_total_chge     decimal(13,2)= 0,
        @F_codtran       smallint     = 0,
        @F_sistema_comex smallint     = 710,
        @F_usr_nombcorto varchar(8)   = '',
        @F_nro_giro      int          = 0,
        @F_monto_giro    decimal(13,2)= 0,
        @F_sigla         varchar(6)   = '',
        @F_linea         varchar(200) = '',
        @F_datos         varchar(max) = '',
        @F_estado_gir_desc varchar(10) = ''
        
declare @t_tran as table (nro_operacion   int,
                          via_sistema     smallint,
                          es_cheque_ajeno bit,
                          importe         decimal(13,2) default 0
                         )        
----------------------------------------------------------------------------------------------------
----  COMEX - GESTION GIROS ENVIADOS
-----------------------------------------------------------------------------------------------------     

--MOSTRAR TITULO
   
   insert into #tabla_reporte
   select 8,1,1,linea_texto = ''
   union all select 8,1,1,Linea_texto = '-------------------------------------------------------------------------------------------------------------------------------------------------------------------------' 
   union all Select 8,1,1,Linea_texto = 'MOVIMIENTOS DE GESTIÓN GIROS ENVIADOS AL EXTERIOR'
   union all Select 8,1,1,Linea_texto = 'LISTADO DE SOLICITUD DE GIROS'
   union all Select 8,1,1,Linea_texto = '-------------------------------------------------------------------------------------------------------------------------------------------------------------------------' 
   union all Select 8,1,1,Linea_texto = '                         Cliente                                             Total          Total         Total           Total        Total       Estado       Estado   ' 
   union all Select 8,1,1,Linea_texto = 'Usuario   Comprobante   Ordenante   Nro.Giro       Monto Giro  Moneda       Efectivo      Cta. Cte.    Cja. Ahorro       Contable   Cheque Ajeno    Giro       Registro  ' 
   union all Select 8,1,1,Linea_texto = '-------------------------------------------------------------------------------------------------------------------------------------------------------------------------'    
                         
--INICIALIZAR VARIABLES
set @F_Total_Comp = 0                         
set @F_sistema_comex = 710                     

--OBTENER COD.TRAN DE LA SOLICITUD
select @F_codtran = cod_tran 
  from pamcmx_tipo_movimiento 
where sistema_comex   = @F_sistema_comex 
  and tipo_movimiento = 1    --Solicitud de Giro
  and indicador       = 'A'
  and fecha_proceso_hasta = '01-01-2050'

insert into @tb_temporal_cmx
select u.nombcorto,g.nro_giro,g.cliente,g.monto_giro,t.comprobante,m.sigla,t.indicador, c.descripcion
from cmxgirmst_maestro g,cmxgirtrn_trans t,climst_usuario u,pam_moneda m, pamcmx_datosconcepto c
where g.nro_giro        = t.nro_giro  
  and g.nro_enmienda    = t.nro_enmienda
  and g.sistema         = @F_sistema_comex
  and t.sistema         = @F_sistema_comex
  and t.comprobante_via = 0           --Para q excluya el comprobante de la tran. de ITF
  and g.usuario         = u.cliente 
  and t.cod_tran        = @F_codtran
  and g.moneda          = m.moneda 
  and c.prefijo         = 4           --Estados de Giro
  and c.correlativo     = g.estado
  and cast(g.fecha_solicitud as date)  = @z_fecha_proceso
  and ((@I_indicador='' and 1=1) or (@I_indicador<>'' and ((@I_indicador='R' and t.indicador = @I_indicador) or (@I_indicador='A' and t.indicador in ('A','P')))))
  and ((@I_usuario  = 0 and 1=1) or (@I_usuario>0 and g.usr_solicitud = @I_usuario))
  and ((@I_agencia  = 0 and 1=1) or (@I_agencia>0 and g.agencia       = @I_agencia))
  and u.indicador       = 'A'
  and m.indicador       = 'A'
  and c.indicador       = 'A'
  and c.fecha_proceso_hasta = '01-01-2050'
order by u.nombcorto,g.nro_giro 

  	select  @F_maxsec =max(id), @F_count=min(id) from @tb_temporal_cmx
  	select @F_count =isnull(@F_count,1),
          @F_maxsec =isnull(@F_maxsec,0)

while (@F_count <= @F_maxsec)  
begin
     select @F_usr_nombcorto  =usr_nombcorto  ,
            @F_nro_giro       =nro_giro       ,
            @F_cliente        =cliente        ,
            @F_monto_giro     =monto_giro     ,
            @F_comprobante    =comprobante    ,
            @F_sigla          =sigla          ,
            @F_indicador      =indicador      ,
            @F_estado_gir_desc=estado_gir_desc
      	from @tb_temporal_cmx t
      where t.id = @F_count  
   --INICIALIZAR VARIABLES
   select @F_linea     = '',
          @F_monto_cja = 0,
          @F_monto_cct = 0,
          @F_monto_cah = 0,
          @F_monto_cbl = 0,
          @F_monto_chq = 0
          
   --LIMPIA LAS TRANSACCIONES DEL GIRO ANTERIOR
   delete from @t_tran

   --INSERTAR LAS TRANSACCIONES POR VIAS-PAGO DEL GIRO
   insert into @t_tran
   SELECT b.nro_giro,a.via_sistema,a.es_cheque_ajeno,sum(a.importe_ope) as importe 
    from cmxgirtrn_viaspago a, cmxgirtrn_trans b
   WHERE a.comprobante = b.comprobante 
     and a.sistema   = @F_sistema_comex
     and b.sistema   = @F_sistema_comex
     and b.cod_tran  = @F_codtran
     and ((@I_indicador='' and 1=1) or (@I_indicador<>'' and ((@I_indicador='R' and b.indicador = @I_indicador) or (@I_indicador='A' and b.indicador in ('A','P'))))) 
     and b.nro_giro  = @F_nro_giro
   group by b.nro_giro,a.via_sistema,a.es_cheque_ajeno  
   order by b.nro_giro 

   select @F_monto_cja = (case when via_sistema = 30 then importe else @F_monto_cja end),
          @F_monto_cct = (case when via_sistema = 100 then importe else @F_monto_cct end),
          @F_monto_cah = (case when via_sistema = 200 then importe else @F_monto_cah end), 
          @F_monto_cbl = (case when (via_sistema = 910 and es_cheque_ajeno = 0) then importe else @F_monto_cbl end),
          @F_monto_chq = (case when (via_sistema = 910 and es_cheque_ajeno = 1) then importe else @F_monto_chq end)
   from @t_tran   

   select @F_linea = cast(@F_usr_nombcorto as CHAR(8)) +SPACE(2)+
                     cast(@F_comprobante as CHAR(12))  +SPACE(2)+ 
                     cast(@F_cliente as CHAR(10))      +SPACE(2)+    
                     cast(@F_nro_giro as CHAR(10))     +SPACE(2)+     
                     str(@F_monto_giro,13,2)           +SPACE(2)+  
                     cast(@F_sigla as CHAR(6))         +SPACE(2)+       
                     str(@F_monto_cja,13,2)            +SPACE(2)+
                     str(@F_monto_cct,13,2)            +SPACE(2)+
                     str(@F_monto_cah,13,2)            +SPACE(2)+
                     str(@F_monto_cbl,13,2)            +SPACE(2)+
                     str(@F_monto_chq,13,2)            +SPACE(2)+
                     cast(@F_estado_gir_desc as CHAR(10))+SPACE(6)+
                     cast((case @F_indicador when 'P' then 'A' else @F_indicador end) as CHAR(8))           
                       
   set @F_datos = @F_datos + (case when LEN(@F_datos)>0 then (CHAR(13)+@F_linea) else @F_linea end) 

   --SUMAR TOTALES
   select @F_total_cja = @F_total_cja + @F_monto_cja,
          @F_total_cah = @F_total_cah + @F_monto_cah,
          @F_total_cct = @F_total_cct + @F_monto_cct,
          @F_total_cbl = @F_total_cbl + @F_monto_cbl,
          @F_total_chq = @F_total_chq + @F_monto_chq
          
   --INCREMENTAR CONTADOR DE REGISTROS
   SET @F_Total_Comp = @F_Total_Comp +1       
   set @F_count=@F_count+1

end /** FIN DEL WHILE **/

-- MOSTRAR DATOS
if ltrim(rtrim(@F_datos))<>''    
begin
    insert into #tabla_reporte
    Select 8,1,1,Linea_texto = @F_datos 
end

insert into #tabla_reporte
Select 8,1,1,Linea_texto=REPLICATE('-',170)+CHAR(13)+
               'Total Operaciones --> '+ CAST(@F_Total_Comp as CHAR(10)) +SPACE(39)+ 
               str(@F_total_cja,13,2) +SPACE(2)+
               str(@F_total_cct,13,2) +SPACE(2)+
               str(@F_total_cah,13,2) +SPACE(2)+
               str(@F_total_cbl,13,2) +SPACE(2)+
               str(@F_total_chq,13,2)          


      set @RowCount=0
      select @RowCount=count(id) from #tabla_reporte where tipo =8 and subtipo=1   
      
      if @RowCount = 9--Cantidad de lineas que ocupa el header(6) y footer(2)
      begin 
            update #tabla_reporte set  visible=0 where tipo =8 and subtipo=1                  
      end

----------------------------------------------------------------------------------------------------
----  FIN COMEX - GESTION GIROS ENVIADOS
-----------------------------------------------------------------------------------------------------     

----------------------------------------------------------------------------------------------------
----  COMEX - GIROS ENVIADOS AL EXTERIOR (SISTEMA=740)
-----------------------------------------------------------------------------------------------------     

--MOSTRAR TITULO
   insert into #tabla_reporte
   select 8,2,1,linea_texto           = ''
   union all select 8,2,1,Linea_texto = '-------------------------------------------------------------------------------------------------------------------------------------------------------------------------' 
   union all Select 8,2,1,Linea_texto = 'MOVIMIENTOS DE GIROS ENVIADOS AL EXTERIOR'
 set @F_sec = 3
 while @F_sec <= 5
 begin
    set @F_Tipo_mov= case when @F_sec=3 then 1  --SOLICITUD
                          when @F_sec=4 then 11 --COBRO CARGOS Y COMISIONES
                          when @F_sec=5 then 12 --COBRO CARGOS DE CORRESPONSAL
                          else 0
                     end    
    insert into #tabla_reporte  
    Select 8,@F_sec,1,Linea_texto = case when @F_Tipo_mov=1  then 'LISTADO SOLICITUD DE GIROS'
                                         when @F_Tipo_mov=11 then 'LISTADO COBRO CARGOS Y COMISIONES'
                                         when @F_Tipo_mov=12 then 'LISTADO COBRO CARGOS DE CORRESPONSAL'
                                         else '' end
    insert into #tabla_reporte
    Select 8,@F_sec,1,Linea_texto           = '--------------------------------------------------------------------------------------------------------------------------------------------------------------' 
    union all Select 8,@F_sec,1,Linea_texto = '                          Cliente                                              Total          Total         Total           Total         Total      Estado   ' 
    union all Select 8,@F_sec,1,Linea_texto = 'Usuario   Comprobante    Ordenante     Nro.Giro       Monto.Tran  Moneda       Efectivo      Cta. Cte.    Cja. Ahorro       Contable   Cheque Ajeno  Registro ' 
    union all Select 8,@F_sec,1,Linea_texto = '--------------------------------------------------------------------------------------------------------------------------------------------------------------'   
                         
--INICIALIZAR VARIABLES
set @F_Total_Comp    = 0                         
set @F_sistema_comex = 740
set @F_datos = ''
set @F_total_cja = 0    
set @F_total_cct = 0    
set @F_total_cah = 0    
set @F_total_cbl = 0    
set @F_total_chq = 0    


--OBTENER COD.TRAN DE LA SOLICITUD
select @F_codtran = cod_tran 
  from pamcmx_tipo_movimiento 
where sistema_comex   = @F_sistema_comex 
       and tipo_movimiento = @F_Tipo_mov 
  and indicador       = 'A'
  and fecha_proceso_hasta = '01-01-2050'

delete from @tb_temporal_cmx
insert into @tb_temporal_cmx
select u.nombcorto,g.nro_giro,g.cliente,g.monto_giro,t.comprobante,m.sigla,t.indicador, c.descripcion
from cmxgirmst_maestro g,cmxgirtrn_trans t,climst_usuario u,pam_moneda m, pamcmx_datosconcepto c
where g.nro_giro        = t.nro_giro  
  and g.nro_enmienda    = t.nro_enmienda
  and g.sistema         = @F_sistema_comex
  and t.sistema         = @F_sistema_comex
  and t.comprobante_via = 0           --Para q excluya el comprobante de la tran. de ITF
  and g.usuario         = u.cliente 
  and t.cod_tran        = @F_codtran
  and g.moneda          = m.moneda 
  and c.prefijo         = 4           --Estados de Giro
  and c.correlativo     = g.estado
      and cast(t.fecha_proceso as date)  = @z_fecha_proceso
  and ((@I_indicador='' and 1=1) or (@I_indicador<>'' and ((@I_indicador='R' and t.indicador = @I_indicador) or (@I_indicador='A' and t.indicador in ('A','P')))))
      and ((@I_usuario  = 0 and 1=1) or (@I_usuario>0 and t.usuario  = @I_usuario)) 
      and ((@I_agencia  = 0 and 1=1) or (@I_agencia>0 and t.agencia       = @I_agencia))
  and u.indicador       = 'A'
  and m.indicador       = 'A'
  and c.indicador       = 'A'
  and c.fecha_proceso_hasta = '01-01-2050'
order by u.nombcorto,g.nro_giro 


select  @F_maxsec =max(id), @F_count=min(id) from @tb_temporal_cmx
  	select @F_count =isnull(@F_count,1),
          @F_maxsec =isnull(@F_maxsec,0)

while (@F_count <= @F_maxsec)  
begin
select @F_usr_nombcorto  =usr_nombcorto  ,
       @F_nro_giro       =nro_giro       ,
       @F_cliente        =cliente        ,
       @F_monto_giro     =monto_giro     ,
       @F_comprobante    =comprobante    ,
       @F_sigla          =sigla          ,
       @F_indicador      =indicador      ,
       @F_estado_gir_desc=estado_gir_desc
      	from @tb_temporal_cmx t
      where t.id = @F_count  
   --INICIALIZAR VARIABLES
   select @F_linea     = '',
          @F_monto_cja = 0,
          @F_monto_cct = 0,
          @F_monto_cah = 0,
          @F_monto_cbl = 0,
          @F_monto_chq = 0
          
   --LIMPIA LAS TRANSACCIONES DEL GIRO ANTERIOR
   delete from @t_tran

   --INSERTAR LAS TRANSACCIONES POR VIAS-PAGO DEL GIRO
   insert into @t_tran
   SELECT b.nro_giro,a.via_sistema,a.es_cheque_ajeno,sum(a.importe_ope) as importe 
    from cmxgirtrn_viaspago a, cmxgirtrn_trans b
   WHERE a.comprobante = b.comprobante 
     and a.sistema   = @F_sistema_comex
     and b.sistema   = @F_sistema_comex
     and b.cod_tran  = @F_codtran
     and ((@I_indicador='' and 1=1) or (@I_indicador<>'' and ((@I_indicador='R' and b.indicador = @I_indicador) or (@I_indicador='A' and b.indicador in ('A','P'))))) 
     and b.nro_giro  = @F_nro_giro
   group by b.nro_giro,a.via_sistema,a.es_cheque_ajeno  
   order by b.nro_giro 

       if @@ROWCOUNT>0
       begin 
   select @F_monto_cja = (case when via_sistema = 30 then importe else @F_monto_cja end),
          @F_monto_cct = (case when via_sistema = 100 then importe else @F_monto_cct end),
          @F_monto_cah = (case when via_sistema = 200 then importe else @F_monto_cah end), 
          @F_monto_cbl = (case when (via_sistema = 910 and es_cheque_ajeno = 0) then importe else @F_monto_cbl end),
          @F_monto_chq = (case when (via_sistema = 910 and es_cheque_ajeno = 1) then importe else @F_monto_chq end)
   from @t_tran   

   select @F_linea = cast(@F_usr_nombcorto as CHAR(8)) +SPACE(2)+
                     cast(@F_comprobante as CHAR(12))  +SPACE(2)+ 
                     cast(@F_cliente as CHAR(13))      +SPACE(2)+    
                     cast(@F_nro_giro as CHAR(10))     +SPACE(2)+     
                     str(@F_monto_giro,13,2)           +SPACE(2)+  
                     cast(@F_sigla as CHAR(6))         +SPACE(2)+       
                     str(@F_monto_cja,13,2)            +SPACE(2)+
                     str(@F_monto_cct,13,2)            +SPACE(2)+
                     str(@F_monto_cah,13,2)            +SPACE(2)+
                     str(@F_monto_cbl,13,2)            +SPACE(2)+
                     str(@F_monto_chq,13,2)            +SPACE(2)+
                     cast((case @F_indicador when 'P' then 'A' else @F_indicador end) as CHAR(8))           
                       
   set @F_datos = @F_datos + (case when LEN(@F_datos)>0 then (CHAR(13)+@F_linea) else @F_linea end) 

   --SUMAR TOTALES
   select @F_total_cja = @F_total_cja + @F_monto_cja,
          @F_total_cah = @F_total_cah + @F_monto_cah,
          @F_total_cct = @F_total_cct + @F_monto_cct,
          @F_total_cbl = @F_total_cbl + @F_monto_cbl,
          @F_total_chq = @F_total_chq + @F_monto_chq
          
   --INCREMENTAR CONTADOR DE REGISTROS
   SET @F_Total_Comp = @F_Total_Comp +1       
       end
   set @F_count=@F_count+1

end /** FIN DEL WHILE **/

-- MOSTRAR DATOS
if ltrim(rtrim(@F_datos))<>''    
begin
    insert into #tabla_reporte
    Select 8,@F_sec,1,Linea_texto = @F_datos 
end

insert into #tabla_reporte
Select 8,@F_sec,1,Linea_texto=REPLICATE('-',157)+CHAR(13)+
                'Total Operaciones --> '+ CAST(@F_Total_Comp as CHAR(10)) +SPACE(42)+ 
               str(@F_total_cja,13,2) +SPACE(2)+
               str(@F_total_cct,13,2) +SPACE(2)+
               str(@F_total_cah,13,2) +SPACE(2)+
               str(@F_total_cbl,13,2) +SPACE(2)+
               str(@F_total_chq,13,2)            

      set @RowCount=0
      select @RowCount=count(id) from #tabla_reporte where tipo =8 and subtipo=@F_sec   
      
      if @RowCount = 6--Cantidad de lineas que ocupa el header(6) y footer(2)
      begin 
            update #tabla_reporte set  visible=0 where tipo =8 and subtipo=@F_sec                  
      end

 set @F_sec=@F_sec+1
 end
 
 
 set @RowCount=0
 select @RowCount=count(id) from #tabla_reporte where tipo =8 and subtipo=2 and visible=1   
 if @RowCount = 3--Cantidad de lineas que ocupa el header(6) y footer(2)
 begin 
    update #tabla_reporte set  visible=0 where tipo =8 and subtipo=2 and visible=1                  
 end
----------------------------------------------------------------------------------------------------
----  FIN COMEX - GIROS ENVIADOS
-----------------------------------------------------------------------------------------------------     
      
----------------------------------------------------------------------------------------------------
----  COMEX - GIROS RECIBIDOS DEL EXTERIOR (SISTEMA=750)
-----------------------------------------------------------------------------------------------------     

--MOSTRAR TITULO
   insert into #tabla_reporte
   select 8,6,1,linea_texto           = ''
   union all select 8,6,1,Linea_texto = '-------------------------------------------------------------------------------------------------------------------------------------------------------------------------' 
   union all Select 8,6,1,Linea_texto = 'MOVIMIENTOS DE GIROS RECIBIDOS AL EXTERIOR'
   union all Select 8,6,1,Linea_texto = 'LISTADO DE PAGOS DE GIROS'
   union all Select 8,6,1,Linea_texto = '----------------------------------------------------------------------------------------------------------------------------------------------' 
   union all Select 8,6,1,Linea_texto = '                          Cliente                                               Total          Total         Total           Total    Estado  ' 
   union all Select 8,6,1,Linea_texto = 'Usuario   Comprobante   Beneficiario   Nro.Giro       Monto Giro  Moneda       Efectivo      Cta. Cte.    Cja. Ahorro       Contable  Registro' 
   union all Select 8,6,1,Linea_texto = '----------------------------------------------------------------------------------------------------------------------------------------------'   
                         
--INICIALIZAR VARIABLES
set @F_Total_Comp    = 0                         
set @F_sistema_comex = 750
set @F_datos = ''
set @F_total_cja = 0    
set @F_total_cct = 0    
set @F_total_cah = 0    
set @F_total_cbl = 0    
set @F_total_chq = 0    

--OBTENER COD.TRAN DE LA SOLICITUD
select @F_codtran = cod_tran 
  from pamcmx_tipo_movimiento 
 where sistema_comex   = @F_sistema_comex 
   and tipo_movimiento = 3    --PAGO DE GIRO RECIBIDO
   and indicador       = 'A'
   and fecha_proceso_hasta = '01-01-2050'

delete from @tb_temporal_cmx
insert into @tb_temporal_cmx
select u.nombcorto,g.nro_giro,g.cliente,g.monto_giro,t.comprobante,m.sigla,t.indicador, c.descripcion
  from cmxgirmst_maestro g,cmxgirtrn_trans t,climst_usuario u,pam_moneda m, pamcmx_datosconcepto c
 where g.nro_giro        = t.nro_giro  
   and g.nro_enmienda    = t.nro_enmienda
   and g.sistema         = @F_sistema_comex
   and t.sistema         = @F_sistema_comex   
   and g.usuario         = u.cliente 
   and t.cod_tran        = @F_codtran
   and g.moneda          = m.moneda 
   and c.prefijo         = 12           --Estados de Giro
   and c.correlativo     = g.estado
   and cast(t.fecha_proceso as date)  = @z_fecha_proceso
   and ((@I_indicador='' and 1=1) or (@I_indicador<>'' and ((@I_indicador='R' and t.indicador = @I_indicador) or (@I_indicador='A' and t.indicador in ('A','P')))))
   and ((@I_usuario  = 0 and 1=1) or (@I_usuario>0 and g.usr_solicitud = @I_usuario))
   and ((@I_agencia  = 0 and 1=1) or (@I_agencia>0 and g.agencia       = @I_agencia))
   and u.indicador       = 'A'
   and m.indicador       = 'A'
   and c.indicador       = 'A'
   and c.fecha_proceso_hasta = '01-01-2050'
 order by u.nombcorto,g.nro_giro 


 	select  @F_maxsec =max(id), @F_count=min(id) from @tb_temporal_cmx
  	select @F_count =isnull(@F_count,1),
          @F_maxsec =isnull(@F_maxsec,0)

while (@F_count <= @F_maxsec)  
begin
select @F_usr_nombcorto  =usr_nombcorto  ,
       @F_nro_giro       =nro_giro       ,
       @F_cliente        =cliente        ,
       @F_monto_giro     =monto_giro     ,
       @F_comprobante    =comprobante    ,
       @F_sigla          =sigla          ,
       @F_indicador      =indicador      ,
       @F_estado_gir_desc=estado_gir_desc
      	from @tb_temporal_cmx t
      where t.id = @F_count 
   --INICIALIZAR VARIABLES
   select @F_linea     = '',
          @F_monto_cja = 0,
          @F_monto_cct = 0,
          @F_monto_cah = 0,
          @F_monto_cbl = 0,
          @F_monto_chq = 0
          
   --LIMPIA LAS TRANSACCIONES DEL GIRO ANTERIOR
   delete from @t_tran

   --INSERTAR LAS TRANSACCIONES POR VIAS-PAGO DEL GIRO
   insert into @t_tran
   SELECT b.nro_giro,a.via_sistema,a.es_cheque_ajeno,sum(a.importe_ope) as importe 
     from cmxgirtrn_viaspago a, cmxgirtrn_trans b
    WHERE a.comprobante = b.comprobante 
      and a.sistema   = @F_sistema_comex
      and b.sistema   = @F_sistema_comex
      and b.cod_tran  = @F_codtran
      and ((@I_indicador='' and 1=1) or (@I_indicador<>'' and ((@I_indicador='R' and b.indicador = @I_indicador) or (@I_indicador='A' and b.indicador in ('A','P'))))) 
      and b.nro_giro  = @F_nro_giro
    group by b.nro_giro,a.via_sistema,a.es_cheque_ajeno  
    order by b.nro_giro 

   select @F_monto_cja = (case when via_sistema = 30 then importe else @F_monto_cja end),
          @F_monto_cct = (case when via_sistema = 100 then importe else @F_monto_cct end),
          @F_monto_cah = (case when via_sistema = 200 then importe else @F_monto_cah end), 
          @F_monto_cbl = (case when (via_sistema = 910 and es_cheque_ajeno = 0) then importe else @F_monto_cbl end),
          @F_monto_chq = (case when (via_sistema = 910 and es_cheque_ajeno = 1) then importe else @F_monto_chq end)
     from @t_tran   

   select @F_linea = cast(@F_usr_nombcorto as CHAR(8)) +SPACE(2)+
                     cast(@F_comprobante as CHAR(12))  +SPACE(2)+ 
                     cast(@F_cliente as CHAR(13))      +SPACE(2)+    
                     cast(@F_nro_giro as CHAR(10))     +SPACE(2)+     
                     str(@F_monto_giro,13,2)           +SPACE(2)+  
                     cast(@F_sigla as CHAR(6))         +SPACE(2)+       
                     str(@F_monto_cja,13,2)            +SPACE(2)+
                     str(@F_monto_cct,13,2)            +SPACE(2)+
                     str(@F_monto_cah,13,2)            +SPACE(2)+
                     str(@F_monto_cbl,13,2)            +SPACE(2)+                   
                     cast((case @F_indicador when 'P' then 'A' else @F_indicador end) as CHAR(8))           
                       
   set @F_datos = @F_datos + (case when LEN(@F_datos)>0 then (CHAR(13)+@F_linea) else @F_linea end) 

   --SUMAR TOTALES
   select @F_total_cja = @F_total_cja + @F_monto_cja,
          @F_total_cah = @F_total_cah + @F_monto_cah,
          @F_total_cct = @F_total_cct + @F_monto_cct,
          @F_total_cbl = @F_total_cbl + @F_monto_cbl,
          @F_total_chq = @F_total_chq + @F_monto_chq
          
   --INCREMENTAR CONTADOR DE REGISTROS
   SET @F_Total_Comp = @F_Total_Comp +1       

   --SIGUIENTE REGISTRO
   set @f_count=@f_count+1
end /** FIN DEL WHILE **/


-- MOSTRAR DATOS
if ltrim(rtrim(@F_datos))<>''    
begin
    insert into #tabla_reporte
    Select 8,6,1,Linea_texto = @F_datos 
end

insert into #tabla_reporte
Select 8,6,1,Linea_texto=REPLICATE('-',142)+CHAR(13)+
               'Total Operaciones --> '+ CAST(@F_Total_Comp as CHAR(10)) +SPACE(42)+ 
               str(@F_total_cja,13,2) +SPACE(2)+
               str(@F_total_cct,13,2) +SPACE(2)+
               str(@F_total_cah,13,2) +SPACE(2)+
               str(@F_total_cbl,13,2)            

      set @RowCount=0
      select @RowCount=count(id) from #tabla_reporte where tipo =8 and subtipo=6   
      
      --SET @O_error_msg ='@RowCount: ' +str(@RowCount)
      -- GOTO Error
      if @RowCount = 9--Cantidad de lineas que ocupa el header(6) y footer(2)
      begin 
            update #tabla_reporte set  visible=0 where tipo =8 and subtipo=6                  
      end

----------------------------------------------------------------------------------------------------
----  FIN COMEX - GIROS RECIBIDOS
----------------------------------------------------------------------------------------------------             
  
----------------------------------------------------------------------------------------------------
----  CARTAS DE CREDITO EMITIDA (SISTEMA=760)
----------------------------------------------------------------------------------------------------
 --MOSTRAR TITULO 
 
   insert into #tabla_reporte
   select 9,0,1,linea_texto           = ''
   union all select 9,0,1,Linea_texto = '-------------------------------------------------------------------------------------------------------------------------------------------------------------------------' 
   union all Select 9,0,1,Linea_texto = 'MOVIMIENTOS DE CARTAS DE CRÉDITOS EMITIDAS'
 
 set @F_sec = 1
 while @F_sec <= 7
 begin
 set @F_Tipo_mov= case when @F_sec=1 then 4
                       when @F_sec=2 then 5
                       when @F_sec=3 then 6
                       when @F_sec=4 then 7
                       when @F_sec=5 then 8
                       when @F_sec=6 then 9
                       when @F_sec=7 then 15
                       else 0
                  end    
           
           insert into #tabla_reporte  
           Select 9,@F_sec,1,Linea_texto = case when @F_Tipo_mov=4 then 'LISTADO EMISION CARTA CREDITO EMITIDA'
                                     when @F_Tipo_mov=5 then 'LISTADO NEGOCIACION CARTA CREDITO EMITIDA'
                                     when @F_Tipo_mov=6 then 'LISTADO PAGOS CARTA CREDITO EMITIDA'
                                     when @F_Tipo_mov=7 then 'LISTADO BAJA CARTA CREDITO EMITIDA'
                                     when @F_Tipo_mov=8 then 'LISTADO HABILITACION CARTA CREDITO EMITIDA'
                                     when @F_Tipo_mov=9 then 'LISTADO COBRO CARGOS Y COMISIONES'
                                     when @F_Tipo_mov=15 then 'LISTADO EJECUCION ENMIENDA'
                                     else '' end
 
 insert into #tabla_reporte
 Select 9,@F_sec,1,Linea_texto = '-------------------------------------------------------------------------------------------------------------------------------------------------------------' 
 union all Select 9,@F_sec,1,Linea_texto = '                          Cliente                                               Total          Total         Total           Total         Total     Estado  ' 
 union all Select 9,@F_sec,1,Linea_texto = 'Usuario   Comprobante    Ordenante     Nro.Ope        Monto.Ope   Moneda       Efectivo      Cta. Cte.    Cja. Ahorro       Contable   Cheque Ajeno  Registro' 
 union all Select 9,@F_sec,1,Linea_texto = '-------------------------------------------------------------------------------------------------------------------------------------------------------------'   
                         
 --INICIALIZAR VARIABLES
 set @F_Total_Comp    = 0                         
 set @F_sistema_comex = 760
 set @F_datos = ''
 set @F_total_cja = 0    
 set @F_total_cct = 0    
 set @F_total_cah = 0    
 set @F_total_cbl = 0    
 set @F_total_chq = 0    
 
 --OBTENER COD.TRAN DE LA SOLICITUD
 select @F_codtran = cod_tran 
   from pamcmx_tipo_movimiento 
  where sistema_comex   = @F_sistema_comex 
    and tipo_movimiento = @F_Tipo_mov 
    and indicador       = 'A'
    and fecha_proceso_hasta = '01-01-2050'

delete from @tb_temporal_cmx
insert into @tb_temporal_cmx
 select u.nombcorto,g.nro_operacion,g.cliente,g.monto_operacion,t.comprobante,m.sigla,t.indicador, c.descripcion
   from cmxccrmst_maestro g,cmxtrn_trans t,climst_usuario u,pam_moneda m, pamcmx_datosconcepto c
  where g.nro_operacion   = t.nro_operacion  
    and g.nro_enmienda    = t.nro_enmienda
    and g.fecha_proceso_hasta = '01-01-2050' 
    and g.sistema         = @F_sistema_comex
    and t.sistema         = @F_sistema_comex   
    and t.comprobante_via = 0             -- se excluye los itf
    and g.usuario         = u.cliente 
    and t.cod_tran        = @F_codtran
    and t.moneda_ope      = m.moneda 
    and c.prefijo         = 16            -- Estados de cartas
    and c.correlativo     = g.estado
    and t.indicador in ('A','R','P')
    and cast(t.fecha_proceso as date)  = @z_fecha_proceso
    and ((@I_indicador='' and 1=1) or (@I_indicador<>'' and ((@I_indicador='R' and t.indicador = @I_indicador) or (@I_indicador='A' and t.indicador in ('A','P')))))
    and ((@I_usuario  = 0 and 1=1) or (@I_usuario>0 and t.usuario  = @I_usuario))                                   
    and ((@I_agencia  = 0 and 1=1) or (@I_agencia>0 and t.agencia      = @I_agencia))     
    and u.indicador       = 'A'
    and m.indicador       = 'A'
    and c.indicador       = 'A'
    and c.fecha_proceso_hasta = '01-01-2050'
  order by u.nombcorto,g.nro_operacion 
 	select  @F_maxsec =max(id), @F_count=min(id) from @tb_temporal_cmx
  	select @F_count =isnull(@F_count,1),
          @F_maxsec =isnull(@F_maxsec,0)

while (@F_count <= @F_maxsec)  
begin
select @F_usr_nombcorto  =usr_nombcorto  ,
       @F_nro_giro       =nro_giro       ,
       @F_cliente        =cliente        ,
       @F_monto_giro     =monto_giro     ,
       @F_comprobante    =comprobante    ,
       @F_sigla          =sigla          ,
       @F_indicador      =indicador      ,
       @F_estado_gir_desc=estado_gir_desc
      	from @tb_temporal_cmx t
      where t.id = @F_count 
    --INICIALIZAR VARIABLES
    select @F_linea     = '',
           @F_monto_cja = 0,
           @F_monto_cct = 0,
           @F_monto_cah = 0,
           @F_monto_cbl = 0,
           @F_monto_chq = 0
           
    --LIMPIA LAS TRANSACCIONES DEL GIRO ANTERIOR
    delete from @t_tran

    --INSERTAR LAS TRANSACCIONES POR VIAS-PAGO DE LA CARTA
    insert into @t_tran
    SELECT b.nro_operacion,a.sistema_via,a.es_cheque_ajeno,sum(a.monto_ope) as importe 
      from cmxtrn_viaspago a, cmxtrn_trans b
     WHERE a.comprobante = b.comprobante 
       and a.sistema   = @F_sistema_comex
       and b.sistema   = @F_sistema_comex
       and b.cod_tran  = @F_codtran
       and ((@I_indicador='' and 1=1) or (@I_indicador<>'' and ((@I_indicador='R' and b.indicador = @I_indicador) or (@I_indicador='A' and b.indicador in ('A','P'))))) 
       and b.nro_operacion  = @F_nro_giro
       and b.comprobante    = @F_comprobante
     group by b.nro_operacion,a.sistema_via,a.es_cheque_ajeno  
     order by b.nro_operacion     
    if @@ROWCOUNT>0
    begin 
       select @F_monto_cja = (case when via_sistema  = 30  then importe else @F_monto_cja end),
              @F_monto_cct = (case when via_sistema  = 100 then importe else @F_monto_cct end),
              @F_monto_cah = (case when via_sistema  = 200 then importe else @F_monto_cah end), 
              @F_monto_cbl = (case when (via_sistema = 910 and es_cheque_ajeno = 0) then importe else @F_monto_cbl end),
              @F_monto_chq = (case when (via_sistema = 910 and es_cheque_ajeno = 1) then importe else @F_monto_chq end)
         from @t_tran   

       select @F_linea = cast(@F_usr_nombcorto as CHAR(8)) +SPACE(2)+
                         cast(@F_comprobante as CHAR(12))  +SPACE(2)+ 
                         cast(@F_cliente as CHAR(13))      +SPACE(2)+    
                         cast(@F_nro_giro as CHAR(10))     +SPACE(2)+     
                         str(@F_monto_giro,13,2)           +SPACE(2)+  
                         cast(@F_sigla as CHAR(6))         +SPACE(2)+       
                         str(@F_monto_cja,13,2)            +SPACE(2)+
                         str(@F_monto_cct,13,2)            +SPACE(2)+
                         str(@F_monto_cah,13,2)            +SPACE(2)+
                         str(@F_monto_cbl,13,2)            +SPACE(2)+                   
                         str(@F_monto_chq,13,2)            +SPACE(2)+                   
                         cast((case @F_indicador when 'P' then 'A' else @F_indicador end) as CHAR(8))           
                           
       set @F_datos = @F_datos + (case when LEN(@F_datos)>0 then (CHAR(13)+@F_linea) else @F_linea end) 

       --SUMAR TOTALES
       select @F_total_cja = @F_total_cja + @F_monto_cja,
              @F_total_cah = @F_total_cah + @F_monto_cah,
              @F_total_cct = @F_total_cct + @F_monto_cct,
              @F_total_cbl = @F_total_cbl + @F_monto_cbl,
              @F_total_chq = @F_total_chq + @F_monto_chq
              
       --INCREMENTAR CONTADOR DE REGISTROS
       SET @F_Total_Comp = @F_Total_Comp + 1       
    end
    set @f_count=@f_count+1
 end /** FIN DEL WHILE **/
 
-- MOSTRAR DATOS
if ltrim(rtrim(@F_datos))<>''    
begin
    insert into #tabla_reporte
    Select 9,@F_sec,1,Linea_texto = @F_datos 
end

insert into #tabla_reporte
Select 9,@F_sec,1,Linea_texto=REPLICATE('-',157)+CHAR(13)+
                'Total Operaciones --> '+ CAST(@F_Total_Comp as CHAR(10)) +SPACE(42)+ 
                str(@F_total_cja,13,2) +SPACE(2)+
                str(@F_total_cct,13,2) +SPACE(2)+
                str(@F_total_cah,13,2) +SPACE(2)+
                str(@F_total_cbl,13,2) +SPACE(2)+           
                str(@F_total_chq,13,2)      
 
      set @RowCount=0
      select @RowCount=count(id) from #tabla_reporte where tipo =9 and subtipo=@F_sec   
      
      if @RowCount = 6--Cantidad de lineas que ocupa el header(6) y footer(2)
      begin 
            update #tabla_reporte set  visible=0 where tipo =9 and subtipo=@F_sec                  
      end

 
 set @F_sec=@F_sec+1
 end
 
      --Oculta el Titulo del modulo
      set @RowCount=0
      select @RowCount=count(id) from #tabla_reporte where tipo =9 and visible=1   
      
      if @RowCount = 3--Cantidad de lineas que ocupa el header(6) y footer(2)
      begin 
            update #tabla_reporte set  visible=0 where tipo =9  and visible=1                  
      end
----------------------------------------------------------------------------------------------------
----  FIN COMEX - CARTAS DE CREDITOS EMITIDA
----------------------------------------------------------------------------------------------------  

----------------------------------------------------------------------------------------------------
----  CARTAS DE CREDITO RECIBIDAS (SISTEMA=770)
----------------------------------------------------------------------------------------------------
 --MOSTRAR TITULO 
   insert into #tabla_reporte
   select 10,0,1,linea_texto           = ''
   union all select 10,0,1,Linea_texto = '--------------------------------------------------------------------------------------------------------------------------------------------------------------------------' 
   union all Select 10,0,1,Linea_texto = 'MOVIMIENTOS DE CARTAS DE CRÉDITOS RECIBIDAS'
 
 set @F_sec = 1
 while @F_sec <= 3
 begin
 set @F_Tipo_mov= case when @F_sec=1 then 4
                       when @F_sec=2 then 5
                       when @F_sec=3 then 8
                       else 0
                  end    
             
           
           insert into #tabla_reporte  
           Select 10,@F_sec,1,Linea_texto = case when @F_Tipo_mov=4 then 'LISTADO NEGOCIACIONES CARTA CREDITO RECIBIDA'
                                     when @F_Tipo_mov=5 then 'LISTADO PAGOS CARTA CREDITO RECIBIDA'
                                     when @F_Tipo_mov=8 then 'LISTADO COBRO OTROS CARGOS Y COMISIONES'
                                     else '' end
 insert into #tabla_reporte  
 Select 10,@F_sec,1,Linea_texto = '-------------------------------------------------------------------------------------------------------------------------------------------------------------------------' 
 union all Select 10,@F_sec,1,Linea_texto = '                        Cliente                                             Total          Total         Total           Total         Total          Total    Estado    ' 
 union all Select 10,@F_sec,1,Linea_texto = 'Usuario   Comprobante  Ordenante     Nro.Ope    Monto.Ope   Moneda        Efectivo      Cta. Cte.    Cja. Ahorro       Contable   Cheque Ajeno   Cheque Geren. Registro  ' 
 union all Select 10,@F_sec,1,Linea_texto = '-------------------------------------------------------------------------------------------------------------------------------------------------------------------------'   
                         
 --INICIALIZAR VARIABLES
 set @F_Total_Comp    = 0                         
 set @F_sistema_comex = 770
 set @F_datos = ''
 set @F_total_cja = 0    
 set @F_total_cct = 0    
 set @F_total_cah = 0    
 set @F_total_cbl = 0    
 set @F_total_chq = 0 
 set @F_total_chge = 0

 
 --OBTENER COD.TRAN DE LA SOLICITUD
 select @F_codtran = cod_tran 
   from pamcmx_tipo_movimiento 
  where sistema_comex   = @F_sistema_comex 
    and tipo_movimiento = @F_Tipo_mov 
    and indicador       = 'A'
    and fecha_proceso_hasta = '01-01-2050'

 delete from @tb_temporal_cmx
 insert into @tb_temporal_cmx
 select u.nombcorto,g.nro_operacion,g.cliente,g.monto_operacion,t.comprobante,m.sigla,t.indicador, c.descripcion
   from cmxccrmst_maestro g,cmxtrn_trans t,climst_usuario u,pam_moneda m, pamcmx_datosconcepto c
  where g.nro_operacion   = t.nro_operacion  
    and g.nro_enmienda    = t.nro_enmienda
    and g.fecha_proceso_hasta = '01-01-2050' 
    and g.sistema         = @F_sistema_comex
    and t.sistema         = @F_sistema_comex   
    and t.comprobante_via = 0             -- se excluye los itf
    and g.usuario         = u.cliente 
    and t.cod_tran        = @F_codtran
    and t.moneda_ope      = m.moneda 
    and c.prefijo         = 24            -- Estados de cartas
    and c.correlativo     = g.estado
    and t.indicador in ('A','R','P')
    and cast(t.fecha_proceso as date)  = @z_fecha_proceso
    and ((@I_indicador='' and 1=1) or (@I_indicador<>'' and ((@I_indicador='R' and t.indicador = @I_indicador) or (@I_indicador='A' and t.indicador in ('A','P')))))
    and ((@I_usuario  = 0 and 1=1) or (@I_usuario>0 and t.usuario  = @I_usuario))                                   
  --and ((@I_usuario  = 0 and 1=1) or (@I_usuario>0 and g.usr_emision  = @I_usuario and @F_Tipo_mov=4)
  --                               or (@I_usuario>0 and g.usr_pago_ben = @I_usuario and @F_Tipo_mov=6)
  --                               or (@I_usuario>0 and g.usr_emision  = @I_usuario and @F_Tipo_mov=5))
    and ((@I_agencia  = 0 and 1=1) or (@I_agencia>0 and t.agencia      = @I_agencia))     
    and u.indicador       = 'A'
    and m.indicador       = 'A'
    and c.indicador       = 'A'
    and c.fecha_proceso_hasta = '01-01-2050'
  order by u.nombcorto,g.nro_operacion 

 	select  @F_maxsec =max(id), @F_count=min(id) from @tb_temporal_cmx
  	select @F_count =isnull(@F_count,1),
          @F_maxsec =isnull(@F_maxsec,0)

while (@F_count <= @F_maxsec)
 begin
    --INICIALIZAR VARIABLES
    select @F_linea     = '',
           @F_monto_cja = 0,
           @F_monto_cct = 0,
           @F_monto_cah = 0,
           @F_monto_cbl = 0,
           @F_monto_chq = 0,
           @F_monto_chge = 0
           
    --LIMPIA LAS TRANSACCIONES DEL GIRO ANTERIOR
    delete from @t_tran

    --INSERTAR LAS TRANSACCIONES POR VIAS-PAGO DE LA CARTA
    insert into @t_tran
    SELECT b.nro_operacion,a.sistema_via,a.es_cheque_ajeno,sum(a.monto_ope) as importe 
      from cmxtrn_viaspago a, cmxtrn_trans b
     WHERE a.comprobante = b.comprobante 
       and a.sistema   = @F_sistema_comex
       and b.sistema   = @F_sistema_comex
       and b.cod_tran  = @F_codtran
       and ((@I_indicador='' and 1=1) or (@I_indicador<>'' and ((@I_indicador='R' and b.indicador = @I_indicador) or (@I_indicador='A' and b.indicador in ('A','P'))))) 
       and b.nro_operacion  = @F_nro_giro
       and b.comprobante    = @F_comprobante
     group by b.nro_operacion,a.sistema_via,a.es_cheque_ajeno  
     order by b.nro_operacion     
    if @@ROWCOUNT>0
    begin 
       select @F_monto_cja = (case when via_sistema  = 30  then importe else @F_monto_cja end),
              @F_monto_cct = (case when via_sistema  = 100 then importe else @F_monto_cct end),
              @F_monto_cah = (case when via_sistema  = 200 then importe else @F_monto_cah end), 
              @F_monto_cbl = (case when (via_sistema = 910 and es_cheque_ajeno = 0) then importe else @F_monto_cbl end),
              @F_monto_chq = (case when (via_sistema = 910 and es_cheque_ajeno = 1) then importe else @F_monto_chq end),
              @F_monto_chge = (case when (via_sistema = 920) then importe else @F_monto_chge end)
         from @t_tran   

       select @F_linea = cast(@F_usr_nombcorto as CHAR(8)) +SPACE(2)+
                         cast(@F_comprobante as CHAR(12))  +SPACE(2)+ 
                         cast(@F_cliente as CHAR(13))      +SPACE(0.5)+    
                         cast(@F_nro_giro as CHAR(10))     +SPACE(0.5)+     
                         str(@F_monto_giro,13,2)           +SPACE(2)+  
                         cast(@F_sigla as CHAR(6))         +SPACE(2)+       
                         str(@F_monto_cja,13,2)            +SPACE(2)+
                         str(@F_monto_cct,13,2)            +SPACE(2)+
                         str(@F_monto_cah,13,2)            +SPACE(2)+
                         str(@F_monto_cbl,13,2)            +SPACE(2)+                   
                         str(@F_monto_chq,13,2)            +SPACE(2)+                   
                         str(@F_monto_chge,13,2)           +SPACE(3)+                   
                         cast((case @F_indicador when 'P' then 'A' else @F_indicador end) as CHAR(8))           
                           
       set @F_datos = @F_datos + (case when LEN(@F_datos)>0 then (CHAR(13)+@F_linea) else @F_linea end) 

       --SUMAR TOTALES
       select @F_total_cja = @F_total_cja + @F_monto_cja,
              @F_total_cah = @F_total_cah + @F_monto_cah,
              @F_total_cct = @F_total_cct + @F_monto_cct,
              @F_total_cbl = @F_total_cbl + @F_monto_cbl,
              @F_total_chq = @F_total_chq + @F_monto_chq,
              @F_total_chge = @F_total_chge + @F_monto_chge 
              
       --INCREMENTAR CONTADOR DE REGISTROS
       SET @F_Total_Comp = @F_Total_Comp + 1       
    end
    set @F_count=@F_count+1
 end /** FIN DEL WHILE **/


 -- MOSTRAR DATOS
if ltrim(rtrim(@F_datos))<>''    
begin
    insert into #tabla_reporte
    Select 10,@F_sec,1,Linea_texto = @F_datos 
end

insert into #tabla_reporte
Select 10,@F_sec,1,Linea_texto= REPLICATE('-',170)+CHAR(13)+
                'Total Operaciones --> '+ CAST(@F_Total_Comp as CHAR(10)) +SPACE(38)+ 
                str(@F_total_cja,13,2) +SPACE(2)+
                str(@F_total_cct,13,2) +SPACE(2)+
                str(@F_total_cah,13,2) +SPACE(2)+
                str(@F_total_cbl,13,2) +SPACE(2)+           
                str(@F_total_chq,13,2) +SPACE(2)+ 
                str(@F_total_chge,13,2)     
                
                
      set @RowCount=0
      select @RowCount=count(id) from #tabla_reporte where tipo =10 and subtipo=@F_sec   
      
      if @RowCount = 6--Cantidad de lineas que ocupa el header(6) y footer(2)
      begin 
            update #tabla_reporte set  visible=0 where tipo =10 and subtipo=@F_sec                  
      end

 
 set @F_sec=@F_sec+1
 end
 
      --Oculta el Titulo del modulo
      set @RowCount=0
      select @RowCount=count(id) from #tabla_reporte where tipo =10 and visible=1   
      
      if @RowCount = 3--Cantidad de lineas que ocupa el header(6) y footer(2)
      begin 
            update #tabla_reporte set  visible=0 where tipo =10  and visible=1                  
      end
----------------------------------------------------------------------------------------------------
----  FIN COMEX - CARTAS DE CREDITOS RECIBIDAS
---------------------------------------------------------------------------------------------------- 
       
----------------------------------------------------------------------------------------------------
----  FIN MOVIMIENTOS DE COMEX (COMERCIO EXTERIOR)
----------------------------------------------------------------------------------------------------     

-- endregion  
-- region convenios
----------------------------------------------------------------------------------------------------
----  MOVIMIENTOS DE CONVENIOS
----------------------------------------------------------------------------------------------------- 
   if @I_Indicador <>''
      set @F_cadindicador = +'a.indicador§'+@I_Indicador+'¶'
   else
      set @F_cadindicador = ''
   set @F_Criterio = 'a.usuario§' + case @I_Usuario when 0 then '' 
                                    else ltrim(str(@I_Usuario))end+'¶'
                    +'e.agencia§'+ case @I_agencia when 0 then '' 
                                    else ltrim(str(@I_agencia))end+'¶'
                    +@F_cadindicador 
   exec @F_error_exec=Construct_GLB
                       @I_mostrar    = 'N',
                       @IO_construct = @F_Criterio  output,
                       @O_error_msg  = @O_error_msg output
    IF @@error <> 0 
       BEGIN
       SET @O_error_msg ='Error al ejecutar Construct_GLB.'
       GOTO Error
       END   
				IF @F_error_exec <> 0 GOTO Error     
       
   insert into #tabla_reporte
   select 11,1,1,linea_texto           = ''
   union all select 11,1,1,Linea_texto = '---------------------------------------------------------------------------------------------------------------------------------------------------------'
   union all Select 11,1,1,Linea_texto = 'MOVIMIENTOS DE CONVENIOS'
   union all Select 11,1,1,Linea_texto = '---------------------------------------------------------------------------------------------------------------------------------------------------------'
   union all Select 11,1,1,Linea_texto = '                                                             Valida                           Fecha      Usuario  Fecha      Fecha      Usuario   Motivo '
   union all Select 11,1,1,Linea_texto = 'Usuario     Convenio             Código Servicio      Moneda Moneda Facturación Correo        Apertura   Apertura Vcto.      Cancel.    Cancel.   Cancel.'
   union all Select 11,1,1,Linea_texto = '---------------------------------------------------------------------------------------------------------------------------------------------------------'

insert into #tabla_reporte
exec ( 'select 11,1,1,LINEA_TEXTO = cast(e.nombcorto as CHAR(11))+'' ''+ '+
       '       cast(b.nombre_empresa as char(20))+'' ''+  '+
       '       cast(c.descripcion as char(20))+'' ''+ '+
       '       case a.moneda when  1 then ''Bs. '' when 2 then ''$us.'' else ''Otro'' end +''   ''+ '+
       '       case when a.valida_moneda = 1 then ''SI'' else ''NO'' end +''     ''+ '+
       '       case a.facturacion when ''S'' then ''SI'' else ''NO'' end +''          ''+ '+
       '       cast(a.correo as CHAR(13))+'' ''+ '+
       '       convert(char(10), a.fecha_aper,105)+'' ''+ '+
       '       d.nombcorto +'' ''+ '+
       '       convert(char(10),a.fecha_vencimiento,105) +'' ''+ '+
       '       convert(char(10),a.fecha_cancelacion,105)+'' ''+ '+
       '       cast(isnull((select nombcorto from climst_usuario  '+
       '                where cliente = a.usuario_cancelacion and indicador = ''A''),'''') as CHAR(10)) +'' ''+ '+
       '       cast(a.motivo_cancelacion as CHAR(25)) '+
       '  from convmst_convenio_servicio a, '+
       '       convmst_convenio b, '+
       '       pamconv_general c, '+
       '       climst_usuario d, '+
       '       climst_usuario e '+
       ' where '+ @F_Criterio +
       '   and a.fecha_proceso = '+@F_fecha+
       '   and a.fecha_proceso_hasta = ''01-01-2050'' '+
       '   and a.indicador in (''A'',''R'') '+
       '   and a.convenio = b.convenio  '+
       '   and b.fecha_proceso_hasta = ''01-01-2050'' '+
       '   and b.indicador = ''A'' '+
       '   and a.servicio = c.codigo '+
       '   and a.tab_servicio = c.codigo_tabla '+
       '   and c.indicador = ''A'' '+
       '   and c.fecha_proceso_hasta = ''01-01-2050'' '+
       '   and a.usuario_aper = d.cliente '+
       '   and d.indicador = ''A'' '+
       '   and a.usuario = e.cliente '+
       '   and d.indicador = ''A'' ' )   
       
   insert into #tabla_reporte    
   EXEC(' select 11,1,1,linea_texto = ''TOTAL OPER ==> '' + str(isnull(COUNT (a.fecha_proceso),0),10)'+
       '  from convmst_convenio_servicio a, '+
       '       convmst_convenio b, '+
       '       pamconv_general c, '+
       '       climst_usuario d, '+
       '       climst_usuario e '+
       ' where '+ @F_Criterio +
       '   and a.fecha_proceso = '+@F_fecha+
       '   and a.fecha_proceso_hasta = ''01-01-2050'' '+
       '   and a.indicador in (''A'',''R'') '+
       '   and a.convenio = b.convenio  '+
       '   and b.fecha_proceso_hasta = ''01-01-2050'' '+
       '   and b.indicador = ''A'' '+
       '   and a.servicio = c.codigo '+
       '   and a.tab_servicio = c.codigo_tabla '+
       '   and c.indicador = ''A'' '+
       '   and c.fecha_proceso_hasta = ''01-01-2050'' '+
       '   and a.usuario_aper = d.cliente '+
       '   and d.indicador = ''A'' '+
       '   and a.usuario = e.cliente '+
       '   and d.indicador = ''A'' ' ) 
       
    --Oculta el Titulo del modulo
      set @RowCount=0
      select @RowCount=count(id) from #tabla_reporte where tipo =11 and visible=1   
      
      
      --SET @O_error_msg ='@RowCount: ' +str(@RowCount)
      -- GOTO Error
      if @RowCount = 8--Cantidad de lineas que ocupa el header(6) y footer(2)
      begin 
            update #tabla_reporte set  visible=0 where tipo =11  and visible=1                  
      end           
 
-- endregion
-- region chg

------------------------------------------------------------------------------------------------
  --MOVIMIENTOS DE CHEQUE DE GERENCIA
------------------------------------------------------------------------------------------------- 
    insert into #tabla_reporte
    select 11,2,1,linea_texto           = ''
    union all select 11,2,1,Linea_texto = '----------------------------------------------------------------------------------------------------------------------------------' 
    union all Select 11,2,1,Linea_texto = 'MOVIMIENTOS DE CHEQUE DE GERENCIA '
    union all Select 11,2,1,Linea_texto = 'SOLICITUD DE EMISIÓN DE CHEQUE DE GERENCIA'
    union all Select 11,2,1,Linea_texto = '------------------------------------------------------------------------------------------------------------------------------------------------------------------------------' 
    union all Select 11,2,1,Linea_texto = '                         Cliente                           Total         Total         Total           Total       Estado                                          Estado     ' 
    union all Select 11,2,1,Linea_texto = 'Usuario   Comprobante   Ordenante    Monto Cheque Mda     Efectivo      Cta. Cte.    Cja. Ahorro      Contable   Solicitud                                        Registro    ' 
    union all Select 11,2,1,Linea_texto = '------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'    
--------------------------------------------------------------------------------------------------------
--------  MOVIMIENTOS DE CHEQUE DE GERENCIA
--------------------------------------------------------------------------------------------------------- 
    if @I_Indicador <>''
       set @F_cadindicador = +'a.indicador§'+@I_Indicador+'¶'
    else
       set @F_cadindicador = ''
    set @F_Criterio = 'a.usuario§' + case @I_Usuario when 0 then '' 
                                     else ltrim(str(@I_Usuario))end+'¶'
                     +'b.agencia§'+ case @I_agencia when 0 then '' 
                                     else ltrim(str(@I_agencia))end+'¶'
                     +@F_cadindicador 
    exec @F_error_exec=Construct_GLB
                        @I_mostrar    = 'N',
                        @IO_construct = @F_Criterio  output,
                        @O_error_msg  = @O_error_msg output
    IF @@error <> 0 
       BEGIN
       SET @O_error_msg ='Error al ejecutar Construct_GLB.'
       GOTO Error
       END  
				IF @F_error_exec <> 0 GOTO Error    
       
    --*************************************************************
   Declare  @F_str_fecha          varchar(20),
                 @F_ini                int,                 
                 @F_hasta              int,
                 @F_ini1               int,                 
                 @F_hasta1             int,
                 @F_total_efectivo     decimal(13,2),
                 @F_via_sistema        smallint,
                 @F_cuenta_via         decimal(10),
                 @F_str_tipo           varchar(3),              
                 @F_total_contable     decimal(13,2),
                 @F_total_cantidad     int,
                 @F_monto_total        decimal(13,2),
                 @F_str_tipo_reporte   char(3)
    ---------------------------------------------------------------------------------------------------
--    CREANDO LA TABLA TEMPORAL
---------------------------------------------------------------------------------------------------    
    create table #tb_emision  (id int identity(1,1),
                               usuario         int,                               
                               comprobante     decimal(12),
                               cliente         int,
                               monto_total     decimal(13,2),
                               moneda          tinyint,
                               estado          int,
                               indicador       char(1))
                                    
    declare @tb_chequemision table (id int identity(1,1),
                                    nomb_corto   varchar(30),
                                    comprobante  decimal(12),
                                    cliente      int,
                                    monto_total  decimal(13,2),
                                    moneda       tinyint,
                                    estado       int,
                                    indicador    char(1)) 
                                    
   declare @tb_viaspago table (ids int identity(1,1),
                               via_sistema  smallint,
                               importe      decimal(13,2),
                               via_nro_cuenta  decimal(10))   
    set @F_str_fecha = CHAR(39)+CONVERT(char(10),@z_fecha_proceso,105)+CHAR(39)
    
---------------------------------------------------------------------------------------------------
--    INSERTANDO A LA TABLA TEMPORAL
--------------------------------------------------------------------------------------------------- 
    
       insert into #tb_emision
       exec('select (select top 1 x.usuario from chgmst_solicitud x, climst_usuario y where x.comprobante = a.comprobante and x.estado = 1 and x.sistema_via = 920 and x.usuario = y.cliente), '+
            '  a.comprobante, '+
            '  a.depositante, '+
            '  a.monto_a_emitir, '+
            '  a.moneda, '+
            '  a.estado, '+
            '  a.indicador '+
       ' from chgmst_solicitud a  WITH (NOLOCK)' +
       ' where a.tipo_solicitud = 2 ' +
        ' and a.sistema_via = 920 ' +
        ' and a.indicador not in (''N'')  ' +
        ' and a.fecha_solicitud = '+@F_str_fecha+
        ' and a.fecha_proceso_hasta = ''01-01-2050'' ')    
       
     
       insert into @tb_chequemision
       exec ('select isnull(b.nombcorto,''''), 
                     a.comprobante, 
                     a.cliente,
                     a.monto_total, 
                     a.moneda,
                     a.estado,
                     a.indicador
                from #tb_emision as a WITH (NOLOCK)
                     left outer join climov_usuario as b WITH (NOLOCK)
                     on a.usuario  = b.cliente
                       and b.indicador = ''A''
                       and '+@F_str_fecha+' between b.fecha_proceso and b.fecha_proceso_hasta
               where '+@F_Criterio+
                ' and a.indicador not in (''N'')
               order by b.nombcorto, a.comprobante, a.moneda, a.estado  ')               
       select @F_ini   = MIN(id), 
              @F_hasta = MAX(id)
         from @tb_chequemision
       select @F_total_contable = 0,
              @F_total_cah = 0,
              @F_total_cct = 0,
              @F_total_cantidad = 0
       while @F_ini <= @F_hasta
             begin
             select @F_nombcorto    = nomb_corto,
                    @F_comprobante  = comprobante,
                    @F_cliente      = cliente,
                    @F_monto_total  = monto_total,
                    @F_moneda       = moneda,
                    @F_estado       = estado,
                    @F_indicador    = indicador
               from @tb_chequemision
              where id = @F_ini
             
             select @F_total_efectivo = importe
               from cajtrn_puente
              where comprobante = @F_comprobante
                and sistema = 920
                and indicador = 'A'
                
             delete from @tb_viaspago
             insert into @tb_viaspago 
             select via_sistema, importe,via_nro_cuenta
               from chgtrn_viaspago
              where importe > 0
                and comprobante = @F_comprobante
                and via_sistema <>30
             select @F_ini1 = MIN(ids),@F_hasta1 =  MAX(ids) from @tb_viaspago
             
             select @F_total_contable = 0,
                    @F_total_cah      = 0,
                    @F_total_cct      = 0
                            
             while @F_ini1 <= @F_hasta1
                   begin
                   select @F_via_sistema =  via_sistema, 
                          @F_importe =  importe, @F_cuenta_via = via_nro_cuenta
                     from @tb_viaspago
                    where ids = @F_ini1
                   if @F_via_sistema = 910
                      begin
                      select @F_moneda2 = moneda
                        from conmst_plan
                       where cuenta like cast(@F_cuenta_via as char(10))
                         and fecha_proceso_hasta = '01-01-2050'
                      end
                   else
                   if @F_via_sistema = 200
                      begin
                      select @F_moneda2 = moneda
                        from cahmst_maestro
                       where nro_cuenta = @F_cuenta_via
                         and indicador  = 'A'
                      end
                   else
                   if @F_via_sistema = 100
                      begin
                      select @F_moneda2 = moneda
                        from cctmst_maestro
                       where nro_cuenta = @F_cuenta_via
                         and fecha_proceso_hasta = '01-01-2050'
                      end
                    EXEC convertir_moneda_GLB
                                  @I_fecha_proceso      = @z_fecha_proceso,
                                  @I_oficina            = 1,
                                  @I_recibe             = 1,
                                  @I_moneda_entrada     = @F_moneda2,        
                                  @O_moneda_salida      = @F_moneda,       
                                  @I_importe_origen     = @F_importe,
                                  @O_importe_convertido = @F_monto_conver output,
                                  @O_error_msg         = @O_error_msg output
                    IF @@error <> 0 
                       BEGIN
                         SET @O_error_msg ='Error al ejecutar convertir_moneda_GLB.'
                         GOTO Error
                       END   
                    IF @F_error_exec <> 0 GOTO Error
                   if @F_via_sistema = 910
                      set @F_total_contable = @F_total_contable + @F_monto_conver
                   else
                   if @F_via_sistema = 200
                      set @F_total_cah = @F_total_cah + @F_monto_conver
                   else
                   if @F_via_sistema = 100
                      set @F_total_cct = @F_total_cct + @F_monto_conver
                   
                   set @F_ini1 = @F_ini1 + 1
                   end
                   
             if @F_ini <= @F_hasta   
                set @F_total_cantidad = @F_total_cantidad + 1
             set @F_ini = @F_ini + 1
            
            
            insert into #tabla_reporte                                    
            Select 11,2,1,linea_texto = cast(isnull(@F_nombcorto,'') as CHAR(10)) + SPACE(1)+
                                  cast(isnull(@F_comprobante,0) as CHAR(12))+ space(1)+
                                  cast(isnull(@F_cliente,0) as CHAR(10))+ space(1)+
                                  STR(isnull(@F_monto_total,0),13,2)+space(1)+
                                  (case when @F_moneda = 1 then 'Bs.' else 'Sus' end)+SPACE(1)+ 
                                  STR(isnull(@F_total_efectivo,0),13,2)+ SPACE(1)+ 
                                  STR(isnull(@F_total_cct,0),13,2)+ SPACE(1)+ 
                                  STR(isnull(@F_total_cah,0),13,2)+ SPACE(1)+ 
                                  STR(isnull(@F_total_contable,0),13,2)+space(5)+
                                  cast(isnull((select x.descripcion from pam_tablas x where x.tabla = 231 and x.codigo = @F_estado and x.indicador = 'A' and fecha_proceso_hasta = '01-01-2050'),'')as char(45))  + SPACE(7) +
                                  isnull(@F_indicador,'')
             end
             
        insert into #tabla_reporte                                    
        Select 11,2,1,linea_texto = 'Total operaciones ===> '+cast(isnull(@F_total_cantidad,0)as CHAR(10))+SPACE(8)
       
       
      set @RowCount=0
      select @RowCount=count(id) from #tabla_reporte where tipo =11 and subtipo=2   
      
      if @RowCount = 9--Cantidad de lineas que ocupa el header(7) y footer(2)
      begin 
            update #tabla_reporte set  visible=0 where tipo =11 and subtipo=2                  
      end
    --*************************************************************   
 ------------------------------------------------------------------------------------------------     
    if @I_Indicador <>''
       set @F_cadindicador = +'a.indicador§'+@I_Indicador+'¶'
    else
       set @F_cadindicador = ''
    set @F_Criterio = 'a.usr_en_custodio§' + case @I_Usuario when 0 then '' 
                                     else ltrim(str(@I_Usuario))end+'¶'
                     +'c.agencia§'+ case @I_agencia when 0 then '' 
                                     else ltrim(str(@I_agencia))end+'¶'
                     +@F_cadindicador 
    exec @F_error_exec=Construct_GLB
                        @I_mostrar    = 'N',
                        @IO_construct = @F_Criterio  output,
                        @O_error_msg  = @O_error_msg output
    IF @@error <> 0 
       BEGIN
       SET @O_error_msg ='Error al ejecutar Construct_GLB.'
       GOTO Error
       END  
				IF @F_error_exec <> 0 GOTO Error    
    ----  RECEPCION DE CHEQUE DE GERENCIA
    insert into #tabla_reporte
    select 11,3,1,linea_texto           = ''
    union all select 11,3,1,Linea_texto = '--------------------------------------------------------------------------------------------------------------------------' 
    union all Select 11,3,1,Linea_texto = 'RECEPCIÓN DE CHEQUERA DE GERENCIA'
    union all Select 11,3,1,Linea_texto = '--------------------------------------------------------------------------------------------------------------------------' 
    union all Select 11,3,1,Linea_texto = '           Nro.             Nro. de             Nro. de                  Estado                   Tipo de                 ' 
    union all Select 11,3,1,Linea_texto = 'Usuario    Solicitud  Mda  Cheque Inicial      Cheque Final             de Cheque                 Cheque                  ' 
    union all Select 11,3,1,Linea_texto = '--------------------------------------------------------------------------------------------------------------------------'
    
    --****************************************************************************
               
    --Tipo =2
    set @F_str_tipo = char(39)+'6'+char(39)
    set @F_str_tipo_reporte =  char(39)+'2'+ char(39)     
    
   insert into #tabla_reporte 
   Exec('select 11,3,1,linea_texto = cast(ISNULL(c.nombcorto,'''') as char(10))+space(1)+  '+
                                               ' cast(isnull(a.nro_solicitud,0) as char(10))+SPACE(1)+ '+
                                               ' cast((case when a.moneda =1 then ''Bs.'' else ''Sus.'' end) as char(5))+SPACE(1)+ '+
                                               ' cast(isnull(a.nro_cheque_inicial,0) as char(16))+SPACE(3) + '+
                                               ' cast(isnull(a.nro_cheque_final,0) as char(16))+SPACE(10)+ '+
                                               ' cast(isnull((select x.sigla from pam_tablas x where x.tabla = 206 and x.codigo = a.estado and x.indicador = ''A'' and x.fecha_proceso_hasta = ''01-01-2050'' ),'''')as CHAR(20)) + SPACE(5)+ '+
                                               ' cast(isnull((select x.sigla from pam_tablas x where x.tabla = 18 and x.codigo = a.tipo_cheque and x.indicador = ''A'' and x.fecha_proceso_hasta = ''01-01-2050'' ),'''')as CHAR(20)) '+
                                       ' from chgmst_chequera as a '+   
                                            ' LEFT OUTER JOIN climov_usuario as c '+
                                              ' on (( ' + @F_str_tipo_reporte + '= ''2'' and a.usr_en_custodio = c.cliente ) or (' + @F_str_tipo_reporte + ' = ''3'' and a.usr_habilitada =  c.cliente)) '+
                                              '  and c.indicador = ''A'' '+               
                                              '  and ' + @F_str_fecha + ' between c.fecha_proceso and c.fecha_proceso_hasta '+                      
                                       ' where ' + @F_Criterio + 
                                        ' and a.indicador = ''A'' '+
                                        ' and (( ' + @F_str_tipo_reporte + ' = ''2'' and a.fecha_en_custodio = ' + @F_str_fecha + ') or ( ' +@F_str_tipo_reporte + '= ''3'' and a.fecha_habilitada = ' + @F_str_fecha + ')) '+
                                        ' and a.fecha_proceso_hasta = ''01-01-2050'' '                                               
       )

    insert into #tabla_reporte 
    Exec('select 11,3,1,linea_texto = ''Total Operaciones ===>''+STR(count(*)) '+ 
                                       ' from chgmst_chequera as a '+   
                                            ' LEFT OUTER JOIN climov_usuario as c '+
                                              ' on (( ' + @F_str_tipo_reporte + '= ''2'' and a.usr_en_custodio = c.cliente ) or (' + @F_str_tipo_reporte + ' = ''3'' and a.usr_habilitada =  c.cliente)) '+
                                              '  and c.indicador = ''A'' '+               
                                              '  and ' + @F_str_fecha + ' between c.fecha_proceso and c.fecha_proceso_hasta '+                      
                                       ' where ' + @F_Criterio + 
                                        ' and a.indicador = ''A'' '+
                                        ' and (( ' + @F_str_tipo_reporte + ' = ''2'' and a.fecha_en_custodio = ' + @F_str_fecha + ') or ( ' +@F_str_tipo_reporte + '= ''3'' and a.fecha_habilitada = ' + @F_str_fecha + ')) '+
                                        ' and a.fecha_proceso_hasta = ''01-01-2050'' '                                                              
      )  
    --****************************************************************************        
    
    --exec proc_repchg_movicaptacionemision
    --     @I_fecha_inicio       = @I_fecha_proceso,
    --     @I_fecha_proceso      = @I_fecha_proceso,
    --     @I_tipo               = 2, --RECEPCION
    --     @P_condicion          = @F_Criterio 
         
    
      set @RowCount=0
      select @RowCount=count(id) from #tabla_reporte where tipo =11 and subtipo=3   
      
      if @RowCount = 8--Cantidad de lineas que ocupa el header(7) y footer(2)
      begin 
            update #tabla_reporte set  visible=0 where tipo =11 and subtipo=3                  
      end

    ----  HABILITACION DE CHEQUE DE GERENCIA
    insert into #tabla_reporte
    select 11,4,1,linea_texto           = ''
    union all select 11,4,1,Linea_texto = '--------------------------------------------------------------------------------------------------------------------------' 
    union all Select 11,4,1,Linea_texto = 'HABILITACIÓN DE CHEQUERA DE GERENCIA'
    union all Select 11,4,1,Linea_texto = '--------------------------------------------------------------------------------------------------------------------------' 
    union all Select 11,4,1,Linea_texto = '           Nro.             Nro. de             Nro. de                  Estado                   Tipo de                 ' 
    union all Select 11,4,1,Linea_texto = 'Usuario    Solicitud  Mda  Cheque Inicial      Cheque Final             de Cheque                 Cheque                  ' 
    union all Select 11,4,1,Linea_texto = '--------------------------------------------------------------------------------------------------------------------------'

    if @I_Indicador <>''
       set @F_cadindicador = +'a.indicador§'+@I_Indicador+'¶'
    else
       set @F_cadindicador = ''
    set @F_Criterio = 'a.usr_habilitada§' + case @I_Usuario when 0 then '' 
                                     else ltrim(str(@I_Usuario))end+'¶'
                     +'c.agencia§'+ case @I_agencia when 0 then '' 
                                     else ltrim(str(@I_agencia))end+'¶'
                     +@F_cadindicador 
    exec @F_error_exec=Construct_GLB
                        @I_mostrar    = 'N',
                        @IO_construct = @F_Criterio  output,
                        @O_error_msg  = @O_error_msg output
    IF @@error <> 0 
       BEGIN
       SET @O_error_msg ='Error al ejecutar Construct_GLB.'
       GOTO Error
       END 
				IF @F_error_exec <> 0 GOTO Error    
    
    --****************************************************************************
               
    --Tipo =3
    set @F_str_tipo = char(39)+'7'+char(39)
    set @F_str_tipo_reporte = char(39)+'3'+ char(39)
    
   insert into #tabla_reporte 
   Exec('select 11,4,1,linea_texto = cast(ISNULL(c.nombcorto,'''') as char(10))+space(1)+  '+
                                               ' cast(isnull(a.nro_solicitud,0) as char(10))+SPACE(1)+ '+
                                               ' cast((case when a.moneda =1 then ''Bs.'' else ''Sus.'' end) as char(5))+SPACE(1)+ '+
                                               ' cast(isnull(a.nro_cheque_inicial,0) as char(16))+SPACE(3) + '+
                                               ' cast(isnull(a.nro_cheque_final,0) as char(16))+SPACE(10)+ '+
                                               ' cast(isnull((select x.sigla from pam_tablas x where x.tabla = 206 and x.codigo = a.estado and x.indicador = ''A'' and x.fecha_proceso_hasta = ''01-01-2050'' ),'''')as CHAR(20)) + SPACE(5)+ '+
                                               ' cast(isnull((select x.sigla from pam_tablas x where x.tabla = 18 and x.codigo = a.tipo_cheque and x.indicador = ''A'' and x.fecha_proceso_hasta = ''01-01-2050'' ),'''')as CHAR(20)) '+
                                       ' from chgmst_chequera as a '+   
                                            ' LEFT OUTER JOIN climov_usuario as c '+
                                              ' on (( ' + @F_str_tipo_reporte + '= ''2'' and a.usr_en_custodio = c.cliente ) or (' + @F_str_tipo_reporte + ' = ''3'' and a.usr_habilitada =  c.cliente)) '+
                                              '  and c.indicador = ''A'' '+               
                                              '  and ' + @F_str_fecha + ' between c.fecha_proceso and c.fecha_proceso_hasta '+                      
                                       ' where ' + @F_Criterio + 
                                        ' and a.indicador = ''A'' '+
                                        ' and (( ' + @F_str_tipo_reporte + ' = ''2'' and a.fecha_en_custodio = ' + @F_str_fecha + ') or ( ' +@F_str_tipo_reporte + '= ''3'' and a.fecha_habilitada = ' + @F_str_fecha + ')) '+
                                        ' and a.fecha_proceso_hasta = ''01-01-2050'' '                                               
       )

    insert into #tabla_reporte 
    Exec('select 11,4,1,linea_texto = ''Total Operaciones ===>''+STR(count(*)) '+ 
                                       ' from chgmst_chequera as a '+   
                                            ' LEFT OUTER JOIN climov_usuario as c '+
                                              ' on (( ' + @F_str_tipo_reporte + '= ''2'' and a.usr_en_custodio = c.cliente ) or (' + @F_str_tipo_reporte + ' = ''3'' and a.usr_habilitada =  c.cliente)) '+
                                              '  and c.indicador = ''A'' '+               
                                              '  and ' + @F_str_fecha + ' between c.fecha_proceso and c.fecha_proceso_hasta '+                      
                                       ' where ' + @F_Criterio + 
                                        ' and a.indicador = ''A'' '+
                                        ' and (( ' + @F_str_tipo_reporte + ' = ''2'' and a.fecha_en_custodio = ' + @F_str_fecha + ') or ( ' +@F_str_tipo_reporte + '= ''3'' and a.fecha_habilitada = ' + @F_str_fecha + ')) '+
                                        ' and a.fecha_proceso_hasta = ''01-01-2050'' '                                                              
      )  
    --****************************************************************************        
       
    --exec proc_repchg_movicaptacionemision
    --     @I_fecha_inicio       = @I_fecha_proceso,
    --     @I_fecha_proceso      = @I_fecha_proceso,
    --     @I_tipo               = 3, --HABILITACION
    --     @P_condicion          = @F_Criterio  
         
         
         
     set @RowCount=0
      select @RowCount=count(id) from #tabla_reporte where tipo =11 and subtipo=4   
      
      if @RowCount = 8--Cantidad de lineas que ocupa el header(7) y footer(2)
      begin 
            update #tabla_reporte set  visible=0 where tipo =11 and subtipo=4                  
      end  

-- endregion
-- region atm

   ------------------------------------------------------------------------------------------------
  --EMISION DE VOUCHER
------------------------------------------------------------------------------------------------- 
    insert into #tabla_reporte
    select 11,5,1,linea_texto           = ''
    union all select 11,5,1,Linea_texto = '-----------------------------------------------------------------------------------------------------------------------------------------'     
    union all Select 11,5,1,Linea_texto = 'SOLICITUD DE EMISIÓN DE VOUCHER'    
    union all Select 11,5,1,Linea_texto = '-----------------------------------------------------------------------------------------------------------------------------------------'     
    union all Select 11,5,1,Linea_texto = 'Terminal                             Fecha proceso     Fecha voucher    Hora    Total rech.    Total retr.    Total cap.    Act. Count   '
    union all Select 11,5,1,Linea_texto = '-----------------------------------------------------------------------------------------------------------------------------------------'    
--------------------------------------------------------------------------------------------------------
--------  EMISION DE VOUCHER
---------------------------------------------------------------------------------------------------------          
     if @I_agencia <> 0 and  @I_Usuario <> 0
     begin 
         insert into #tabla_reporte  
         exec ( 'select 11,5,1,linea_texto =             
                     CAST(b.descripcion as CHAR(25)) + space(12) + 
                     CONVERT(varchar(10),a.fecha_proceso,105) + space(8) + 
                     CONVERT(varchar(10),a.fechavoucher,105) + space(7) + 
                     cast(a.hora as CHAR (5)) + space(3) + 
                     cast(a.total_rechazados as CHAR (10)) + space(5) + 
                     cast(a.total_retractados as CHAR (10)) + space(5) + 
                     cast(a.total_capturadas as CHAR (10)) + space(5) +
                     cast(a.activity_count as CHAR (10))
                     from tjttrn_totATM as a , pamtjt_terminal as b
                     where ' +   
                           ' a.agencia = ' + @I_Agencia + ' and ' +
                           ' a.usuario = ' + @I_Usuario + ' and ' +
                           ' a.fecha_proceso = ' + @F_fecha + ' and ' +                           
                           ' a.terminal = b.terminal and ' +
                           ' a.indicador = ''A'' and ' +
                           ' a.fecha_proceso_hasta = ''01-01-2050'' and ' +
                           ' b.indicador = ''A'' and ' +
                           ' b.fecha_proceso_hasta = ''01-01-2050'' and ' +
                           ' b.estado = ''A'' order by fechavoucher asc ')              
     end
     else
     if @I_agencia <> 0
     begin
         insert into #tabla_reporte  
         exec ( 'select 11,5,1,linea_texto =             
                     CAST(b.descripcion as CHAR(25)) + space(12) + 
                     CONVERT(varchar(10),a.fecha_proceso,105) + space(8) + 
                     CONVERT(varchar(10),a.fechavoucher,105) + space(7) + 
                     cast(a.hora as CHAR (5)) + space(3) + 
                     cast(a.total_rechazados as CHAR (10)) + space(5) + 
                     cast(a.total_retractados as CHAR (10)) + space(5) + 
                     cast(a.total_capturadas as CHAR (10)) + space(5) +
                     cast(a.activity_count as CHAR (10))
                     from tjttrn_totATM as a , pamtjt_terminal as b
                     where ' +   
                           ' a.agencia = ' + @I_Agencia + ' and '  +                           
                           ' a.fecha_proceso = ' + @F_fecha + ' and ' +                                                      
                           ' a.terminal = b.terminal and ' +
                           ' a.indicador = ''A'' and ' +
                           ' a.fecha_proceso_hasta = ''01-01-2050'' and ' +
                           ' b.indicador = ''A'' and ' +
                           ' b.fecha_proceso_hasta = ''01-01-2050'' and ' +
                           ' b.estado = ''A'' order by fechavoucher asc ' )              
     end
     else
     if  @I_Usuario <> 0
     begin
         insert into #tabla_reporte  
         exec ( 'select 11,5,1,linea_texto =             
                     CAST(b.descripcion as CHAR(25)) + space(12) + 
                     CONVERT(varchar(10),a.fecha_proceso,105) + space(8) + 
                     CONVERT(varchar(10),a.fechavoucher,105) + space(7) + 
                     cast(a.hora as CHAR (5)) + space(3) + 
                     cast(a.total_rechazados as CHAR (10)) + space(5) + 
                     cast(a.total_retractados as CHAR (10)) + space(5) + 
                     cast(a.total_capturadas as CHAR (10)) + space(5) +
                     cast(a.activity_count as CHAR (10))
                     from tjttrn_totATM as a , pamtjt_terminal as b
                     where ' +                              
                           ' a.usuario = ' + @I_Usuario + ' and ' +
                           ' a.fecha_proceso = ' + @F_fecha + ' and ' +                           
                           ' a.terminal = b.terminal and ' +
                           ' a.indicador = ''A'' and ' +
                           ' a.fecha_proceso_hasta = ''01-01-2050'' and ' +
                           ' b.indicador = ''A'' and ' +
                           ' b.fecha_proceso_hasta = ''01-01-2050'' and ' +
                           ' b.estado = ''A'' order by fechavoucher asc ')                   
     end
     else
         insert into #tabla_reporte  
         exec ( 'select 11,5,1,linea_texto =             
                     CAST(b.descripcion as CHAR(25)) + space(12) + 
                     CONVERT(varchar(10),a.fecha_proceso,105) + space(8) + 
                     CONVERT(varchar(10),a.fechavoucher,105) + space(7) + 
                     cast(a.hora as CHAR (5)) + space(3) + 
                     cast(a.total_rechazados as CHAR (10)) + space(5) + 
                     cast(a.total_retractados as CHAR (10)) + space(5) + 
                     cast(a.total_capturadas as CHAR (10)) + space(5) +
                     cast(a.activity_count as CHAR (10))
                     from tjttrn_totATM as a , pamtjt_terminal as b
                     where ' +                              
                           ' a.fecha_proceso = ' + @F_fecha + ' and ' +                           
                           ' a.terminal = b.terminal and ' +
                           ' a.indicador = ''A'' and ' +
                           ' a.fecha_proceso_hasta = ''01-01-2050'' and ' +
                           ' b.indicador = ''A'' and ' +
                           ' b.fecha_proceso_hasta = ''01-01-2050'' and ' +
                           ' b.estado = ''A'' order by fechavoucher asc')



      set @RowCount=0
      select @RowCount=count(id) from #tabla_reporte where tipo =11 and subtipo=5   
      
      if @RowCount = 6--Cantidad de lineas que ocupa el header(6) y footer(2)
      begin 
            update #tabla_reporte set  visible=0 where tipo =11  and subtipo=5                  
      end

-- endregion
-- region remesadora

-------------------------------------------------------------------------------------------------------------------------
-- MOVIMIENTO DE GENERARCION DEL REPORTE DE REMESA 
-------------------------------------------------------------------------------------------------------------------------
------- Remesadora, clave,  Beneficiario, Teléfono Benef, usuario, fecha+hora.
------                           4      RIAKLJKLJ  , Gabriel Soliz, 74212121, vkramire   01-04-2015 10:15:18 

   if @I_Indicador <>''
      set @F_cadindicador = +'a.indicador§'+@I_Indicador+'¶'
   else
      set @F_cadindicador = ''
      
   set @F_Criterio = 'a.usuario§' + case @I_Usuario when 0 then '' 
                                    else ltrim(str(@I_Usuario))end+'¶'+
                     'a.agencia§' + case @I_agencia when 0 then '' 
                                     else ltrim(str(@I_agencia))end+'¶'
                    + @F_cadindicador 
   exec @F_error_exec=Construct_GLB
                       @I_mostrar    = 'N',
                       @IO_construct = @F_Criterio  output,
                       @O_error_msg  = @O_error_msg output
    IF @@error <> 0 
       BEGIN
       SET @O_error_msg ='Error al ejecutar Construct_GLB.'
       GOTO Error
       END
				IF @F_error_exec <> 0 GOTO Error    
   insert into #tabla_reporte
   select 11,6,1,Linea_texto = ''
   union all Select 11,6,1,Linea_texto = '----------------------------------------------------------' 
   union all Select 11,6,1,Linea_texto = 'LISTADO DE GENERACIÓN DE DATOS DE LAS REMESAS WEBSERVICES '
   union all Select 11,6,1,Linea_texto = '----------------------------------------------------------' 
   union all Select 11,6,1,Linea_texto = '----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------' 
   union all Select 11,6,1,Linea_texto = '    Remesadora                    Clave Beneficiario              Nro Giro                  Beneficiario                       Teléfono Beneficiario Usuario           Fecha/Hora Generación       Código Respuesta WebService                  '
   union all Select 11,6,1,Linea_texto = '----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------' 
  
   insert into #tabla_reporte
   exec('select 11,6,1,linea_texto = STR(a.remesadora,5)+ SPACE(3)+
                        cast(c.nombre_remesadora as CHAR(25))+SPACE(1)+
                        CAST(a.clave_remesa as CHAR(30))+SPACE(2)+
                        cast(SUBSTRING(a.nro_giro,CHARINDEX(''>'',a.nro_giro)+1,(CHARINDEX(''</'',a.nro_giro)-CHARINDEX(''>'',a.nro_giro))-1) as CHAR(25))+SPACE(1)+                        
                        CAST(a.nombre_beneficiario as CHAR(35))+SPACE(1)+
                        CAST(a.telf1_beneficiario as CHAR(21))+SPACE(1)+
                        CAST(b.nombcorto as  CHAR(15))+SPACE(2)+
                        CONVERT(char(10),a.fecha_alta,105)+SPACE(1)+CONVERT(char(8),a.fecha_alta,108 )+SPACE(5)+
																								+space(2)+
                        CAST(a.descripcion as  CHAR(100))
      from girtrn_mov_consulta_remesas as a,
           climst_usuario as b,
           girmst_remesadora as c
    where ' + @F_criterio +'
    and '+ @F_fecha +' between a.fecha_proceso and a.fecha_proceso 
    and a.usuario  = b.cliente
    and a.remesadora =c.remesadora
    and c.fecha_proceso_hasta =''01-01-2050''
    order by a.usuario,a.fecha_alta')
				
     set @RowCount=0
     select @RowCount=count(id) from #tabla_reporte where tipo =11 and subtipo=6   
      
      if @RowCount = 7--Cantidad de lineas que ocupa el header(6) y footer(2)
      begin 
            update #tabla_reporte set  visible=0 where tipo =11  and subtipo=6                  
      end

-- endregion
-- region tfc

-------------------------------------------------------------------------------------------------------------------------
-- MOVIMIENTO DE REPORTE TARJETAS DE CREDITO  
-------------------------------------------------------------------------------------------------------------------------

     
  CREATE TABLE #tmp_tcredito
  ( cod_tran int,
    fecha_proceso smalldatetime,
    linea   varchar(max)
  )   
  
   IF @I_Indicador <>''
      SET @F_cadindicador = +'a.indicador§'+@I_Indicador+'¶'
   ELSE
      SET @F_cadindicador = ''
      
   SET @F_Criterio = 'a.usuario§' + case @I_Usuario when 0 then '' 
                                    else ltrim(str(@I_Usuario))end+'¶'+
                     'a.agencia§' + case @I_agencia when 0 then '' 
                                     else ltrim(str(@I_agencia))end+'¶'
                    + @F_cadindicador 
                    
   EXEC @F_error_exec = CONSTRUCT_GLB
        @I_mostrar    = 'N',
        @IO_construct = @F_Criterio  output,
        @O_error_msg  = @O_error_msg output
    IF @@error <> 0 
       BEGIN
            SET @O_error_msg ='Error al ejecutar Construct_GLB.'
            GOTO Error
       END
				IF @F_error_exec <> 0 GOTO Error    
   
   SET @F_Criterio = REPLACE(@F_criterio,'a.agencia','a.agencia_trn')

   --TRANSACCION FINANCIERA - PAGO
   EXEC @F_error_exec = proc_reptcf_movcaptacion_tcredito
        @I_fecha_inicio = @z_fecha_proceso ,
        @I_fecha_fin    = @z_fecha_proceso,
        @I_tp_reporte   = 1,
        @I_criterio     = @F_criterio ,
        @O_error_msg    = @O_error_msg OUTPUT
     IF @@error <> 0 
        BEGIN
          SET @O_error_msg ='Error al ejecutar proc_reptcf_movcaptacion_tcredito.'
          GOTO Error
        END   
     IF @F_error_exec <> 0 GOTO Error
    
   
         INSERT INTO #tabla_reporte
         select 11,7,1,LINEA_TEXTO= ISNULL( linea,'')
           FROM #tmp_tcredito as t
         ORDER  by cod_tran, fecha_proceso
    
              
         Delete from #tmp_tcredito
         set @RowCount=0
         select @RowCount=count(id) from #tabla_reporte where tipo =11 and subtipo=7   
         if @RowCount = 6 --Cantidad de lineas que ocupa el header(6) y footer(2)
         begin 
               update #tabla_reporte set  visible=0 where tipo =11  and subtipo=7                  
         end         
              


SET @F_Criterio = REPLACE(@F_criterio,'a.usuario','a.gestor_venta')
SET @F_Criterio = REPLACE(@F_criterio,'a.agencia_trn','a.agencia_gestor')

   --TRANSACCION FINANCIERA - PAGO
   EXEC proc_reptcf_movcaptacion_tcredito
        @I_fecha_inicio = @z_fecha_proceso ,
        @I_fecha_fin    = @z_fecha_proceso,
        @I_tp_reporte   = 2,
        @I_criterio     = @F_criterio ,
        @O_error_msg    = @O_error_msg OUTPUT
     IF @@error <> 0 
        BEGIN
          SET @O_error_msg ='Error al ejecutar proc_reptcf_movcaptacion_tcredito.'
          GOTO Error
        END   
     IF @F_error_exec <> 0 GOTO Error
      
      
        insert into #tabla_reporte
         select 11,8,1,LINEA_TEXTO= ISNULL(linea,'')
           FROM #tmp_tcredito as t
         ORDER  by cod_tran, fecha_proceso

         
      set @RowCount=0
      select @RowCount=count(id) from #tabla_reporte where tipo =11 and subtipo=8   
      
      if @RowCount = 4--Cantidad de lineas que ocupa el header(6) y footer(2)
      begin 
            update #tabla_reporte set  visible=0 where tipo =11  and subtipo=8                  
      end         
 
-- endregion
-- region segip

  ---- CONSULTAS AL SEGIP
  
  if @I_Indicador <>''
         set @F_cadindicador = +'a.indicador§'+@I_Indicador+'¶'
      else
         set @F_cadindicador = ''
    set @F_Criterio = 'a.funcionario§' + case @I_Usuario when 0 then '' 
                                     else ltrim(str(@I_Usuario))end+'¶'
                     +'a.agencia§'+ case @I_agencia when 0 then '' 
                                     else ltrim(str(@I_agencia))end+'¶'
                     +@F_cadindicador 
    exec @F_error_exec=Construct_GLB
                        @I_mostrar    = 'N',
                        @IO_construct = @F_Criterio  output,
                        @O_error_msg  = @O_error_msg output
    IF @@error <> 0 
       BEGIN
       SET @O_error_msg ='Error al ejecutar Construct_GLB.'
       GOTO Error
       END 
				IF @F_error_exec <> 0 GOTO Error    
      
    insert into #tabla_reporte
              select 12,1,1,Linea_texto = ''
    union all Select 12,1,1,Linea_texto = '----------------------------------------------------------------------------------------------------------------------------------------------------------------------' 
    union all Select 12,1,1,Linea_texto = 'DETALLE CONSULTA A SEGIP'
    union all Select 12,1,1,Linea_texto = '----------------------------------------------------------------------------------------------------------------------------------------------------------------------' 
    union all Select 12,1,1,Linea_texto = 'Consulta  Nro.Documento  Complemento  Nombre                                   Fecha Nac.     Estado             Destino Operación        U. Consulta   U. Autorizador' 
    union all Select 12,1,1,Linea_texto = '----------------------------------------------------------------------------------------------------------------------------------------------------------------------'
    
---------------------------------------------------------------------------------------------------
--  Creando tabla temporal 
--------------------------------------------------------------------------------------------------- 
    
    create table #tb_temporal1  ( id_consulta       decimal(20),
                                 identificacion     varchar(14),
                                 complemento        varchar(10),
                                 nombre             varchar(100),
                                 fecha_nac          varchar(10)not null,
                                 estado             varchar(100),
                                 funcionario        int,
                                 nombre_funcionario varchar(30),
                                 subzona            decimal(9),
                                 agencia            smallint,
                                 nombre_agencia     varchar(100),
                                 sucursal           char(2),
                                 nombre_sucursal    varchar(50),
                                 autorizador        int,
                                 nombre_autorizador varchar(30),
                                 consultado_segip   char(1),
                                 indicador          char(1),
                                 descripcion_tipo   varchar(100),
                                 agencia_autorizador smallint,
                                 fecha_autorizacion  smalldatetime) 
     
      if @@error <> 0 
      begin
      set @O_error_msg ='ERROR al crear #tb_temporal1.'
      goto Error
      end  
                                
     create table #tb_temporal2 (id                int identity(1,1),
                                id_consulta        decimal(20),
                                identificacion     varchar(14),
                                complemento        varchar(10),
                                nombre             varchar(100),
                                fecha_nac          varchar(10)not null,
                                estado             varchar(100),
                                funcionario        int,
                                nombre_funcionario varchar(30),
                                subzona            decimal(9),
                                agencia            smallint,
                                nombre_agencia     varchar(100),
                                sucursal           char(2),
                                nombre_sucursal    varchar(50),
                                autorizador        int,
                                nombre_autorizador varchar(30),
                                consultado_segip   char(1),
                                indicador          char(1),
                                descripcion_tipo   varchar(100),
                                agencia_autorizador smallint)  
      if @@error <> 0 
      begin
      set @O_error_msg ='ERROR al crear #tb_temporal2.'
      goto Error
      end                
  
---------------------------------------------------------------------------------------------------
--  CONSULTA
---------------------------------------------------------------------------------------------------

    insert into #tb_temporal1
    select c.id_consulta,
       c.identificacion,
       c.complemento,
       rtrim(ltrim(isnull(c.nombre +' ' +c.primer_apellido +' '+ c.segundo_apellido,''))) as nombre,
       c.fecha_nac,
       isnull((select descripcion from pam_tablas 
                where tabla=265 and indicador='A' and fecha_proceso_hasta='01-01-2050' and codigo=e.estado),'') as estado,
       h.usuario as funcionario,
       ISNULL((uf.nombcorto),'' ) AS nombre_funcionario,
       h.subzona,
       a.agencia,
       a.nombre as nombre_agencia,
       a.sucursal,
       s.descripcion as nombre_sucursal,
       ISNULL((case when e.estado in(3,4,8,9) then e.usuario else 0 end),0) as autorizador,
       ISNULL((case when e.estado in(3,4,8,9) then ua.nombcorto else '' end),'')  as nombre_autorizador,
       h.consultado_segip,'A' ,
       isnull((select descripcion from pam_tablas 
                where tabla=421 and indicador='A' and fecha_proceso_hasta='01-01-2050' and codigo=c.destino_oper),'') as descripcion_tipo ,
       ISNULL((case when e.estado in(3,4,8,9) then ua.agencia else 0 end),0) as agencia_autorizador, 
       ISNULL((case when e.estado in(3,4,8,9) then e.fecha_proceso else '01-01-1900' end),'01-01-1900') as fecha_autorizacion          
    from climst_consulta_segip as c inner join climst_detalle_estado_segip as e
         on c.id_consulta=e.id_consulta 
         inner join climst_respuesta_consulta_segip as r
         on r.id_consulta=c.id_consulta
         inner join climst_detalle_consulta_segip as h
         on h.id_consulta=c.id_consulta
         left join pam_agencia a
         on a.agencia in ((select agencia from pam_subagencia 
                        where indicador='A' and fecha_proceso_hasta='01-01-2050' and subagencia in
                       (select subagencia from pam_subzona 
                        where indicador='A' and fecha_proceso_hasta='01-01-2050' and subzona=h.subzona) ))
         left join pam_ciudad as s
         on a.sucursal=s.dpto
         left join climst_usuario as uf
         on uf.cliente=h.usuario
         left join climst_usuario as ua
         on ua.cliente=e.usuario
   where h.fecha_proceso = @z_fecha_proceso 
     and a.indicador='A'
     and s.indicador='A'
     and c.indicador='A'
     and e.indicador='A'
     and r.indicador='A'
     and h.indicador='A'
     and uf.indicador='A'
     and ua.indicador='A'
     
     set @f_condicion_aux=''
    SELECT @f_existe_valor=CHARINDEX('a.funcionario',@F_Criterio)
    if isnull(@f_existe_valor,0)>0
    begin
       -- Obtener la agencia del usuario
       select @F_age_usu_filtro   = agencia
         from climst_usuario 
        where cliente = @I_Usuario
          and indicador ='A'
          
       SELECT @f_condicion_aux=REPLACE(@P_condicion,'a.funcionario','a.agencia='''+str(@F_age_usu_filtro)+''' and a.fecha_autorizacion='''+Convert(char(10),@z_fecha_proceso,105)+''' and a.autorizador') 
    end  
    SELECT @f_existe_valor=CHARINDEX('a.agencia',@F_Criterio)
    if isnull(@f_existe_valor,0)>0
       SELECT @f_condicion_aux=REPLACE(@F_Criterio,'a.agencia','a.agencia='''+str(@I_agencia)+''' and a.fecha_autorizacion='''+Convert(char(10),@z_fecha_proceso,105)+''' and a.agencia_autorizador') 
   
    if len(@f_condicion_aux) >0
       set @F_Criterio=@F_Criterio +' or ( '+@f_condicion_aux +' )'
    insert into #tb_temporal2
    exec (' select a.id_consulta, a.identificacion,a.complemento,a.nombre,
                   a.fecha_nac,a.estado,a.funcionario,
                   a.nombre_funcionario,a.subzona,a.agencia,a.nombre_agencia,a.sucursal,
                   a.nombre_sucursal,a.autorizador,a.nombre_autorizador,a.consultado_segip ,a.indicador ,a.descripcion_tipo,a.agencia_autorizador
              from #tb_temporal1 as a
             where '+@F_Criterio)
  
     
    select @f_total_consulta = count(*) from #tb_temporal2 
    
     
    select @F_ini =  min(id), @F_hasta =  max(id)
      from #tb_temporal2  
      
    select @f_total_consulta = count(*) from #tb_temporal2 
    while @F_ini <= @F_hasta and @F_hasta > 0
          begin
          select @f_id_consulta=c.id_consulta,
                 @f_identificacion=c.identificacion,
                 @f_complemento=c.complemento,
                 @f_nombre=c.nombre,
                 @f_fecha_nac=c.fecha_nac,
                 @f_nombre_estado=c.estado,
                 @f_funcionario= c.funcionario,
                 @f_nombre_funcionario= c.nombre_funcionario,
                 @f_subzona=c.subzona,
                 @f_agencia=c.agencia,
                 @f_nombre_agencia=  c.nombre_agencia,
                 @f_sucursal=c.sucursal,
                 @f_nombre_sucursal=c.nombre_sucursal,
                 @f_autorizador=c.autorizador,
                 @f_nombre_autorizador= c.nombre_autorizador,
                 @f_consultado_segip= (case when c.consultado_segip='S' then 'SI'else 'NO' end),
                 @f_descripcion_tipo=descripcion_tipo
            from #tb_temporal2 as c
           where c.id=@F_ini
            
          insert into #tabla_reporte                
          select 12,1,1,linea_texto = cast(str(@f_id_consulta) as CHAR(10))+ SPACE(1)+                   
                               cast(@f_identificacion as CHAR(10))+SPACE(10)+
                               cast(@f_complemento as CHAR(10))+SPACE(1)+
                               cast(@f_nombre as CHAR(40))+SPACE(1)+
                               cast(@f_fecha_nac as CHAR(10))+SPACE(2)+
                               cast(@f_nombre_estado as CHAR(20))+SPACE(5)+
                               CAST(@f_descripcion_tipo as CHAR(20))+SPACE(1)+
                               cast(@f_nombre_funcionario as CHAR(10))+SPACE(1)+
                               cast(@f_nombre_autorizador as CHAR(10))+SPACE(1)
                                                                
                                                                                                 
          set @F_ini = @F_ini  + 1
     end
     
     insert into #tabla_reporte
     select 12,1,1,linea_texto = 'Total operaciones ===> '+cast(isnull(@f_total_consulta,0)as CHAR(10))+SPACE(8)
      
  
     set @RowCount=0
      select @RowCount=count(id) from #tabla_reporte where tipo =12 and subtipo=1   
      
      if @RowCount = 7--Cantidad de lineas que ocupa el header(6) y footer(2)
      begin 
            update #tabla_reporte set  visible=0 where tipo =12  and subtipo=1                  
      end  

-- endregion
-- region token

 ------------------------------------------------------------------------------------------------ 
 -- ASIGNACION DE TOKEN
 ------------------------------------------------------------------------------------------------ 
    set @F_Criterio = ''
    set @F_Criterio = 'a.usuario§' + case @I_Usuario when 0 then '' 
                                     else ltrim(str(@I_Usuario))end+'¶'
                     +'a.agencia_usr§'+ case @I_agencia when 0 then '' 
                                     else ltrim(str(@I_agencia))end+'¶'
    exec @F_error_exec=Construct_GLB
                        @I_mostrar    = 'N',
                        @IO_construct = @F_Criterio  output,
                        @O_error_msg  = @O_error_msg output
    IF @@error <> 0 
       BEGIN
       SET @O_error_msg ='Error al ejecutar Construct_GLB.'
       GOTO Error
       END  
				IF @F_error_exec <> 0 GOTO Error     
    insert into #tabla_reporte
    select 13,1,1,linea_texto           = ''
    union all select 13,1,1,Linea_texto = '-----------------------------------------------------------------------------------------------------' 
    union all Select 13,1,1,Linea_texto = 'ASIGNACIÓN DE TOKEN '
    union all Select 13,1,1,Linea_texto = '------------------------------------------------------------------------------------------------------' 
    union all Select 13,1,1,Linea_texto = '                           Nro.        Código                   Agencia                  Estado       ' 
    union all Select 13,1,1,Linea_texto = 'Comprobante     Usuario    Token       Serial                   Destino                  Actual       ' 
    union all Select 13,1,1,Linea_texto = '------------------------------------------------------------------------------------------------------'
    
    --****************************************************************************
   insert into #tabla_reporte 
   exec ('select 13,1,1,linea_texto = cast(a.comprobante  as char(16)) + space(1)+ ' +
                                     ' cast(ISNULL(a.nombcorto,'''') as char(10))+space(1)+  ' +
                                               ' cast(isnull(a.id_token,0) as char(10))+SPACE(1)+ ' +
                                               ' cast(isnull(a.cod_serial,'''') as char(20))+SPACE(1)+ ' +
                                               ' str(isnull(agencia_destino,0),8) + ''-'' + ' +
                                               ' cast(a.desc_agencia_destino as char(15)) + space(3) +' +
                                               ' str(isnull(a.estado,0),5) + ''-'' + '+
                                               ' cast(isnull(a.nomb_estado,'''')as CHAR(20)) ' +
                                       ' from dbo.fnt_fslnet_MovimientoToken ('+@F_str_fecha + ',' + @F_str_fecha + ' , 1) as a '+                                                   
                                       ' where ' + @F_Criterio )    
    insert into #tabla_reporte 
    Exec('select 13,1,1,linea_texto = ''Total Operaciones ===>''+STR(count(*)) ' + 
                                       ' from fnt_fslnet_MovimientoToken ('+@F_str_fecha + ',' + @F_str_fecha + ' , 1) as a ' +                                                      
                                       ' where ' + @F_Criterio                                                               
      )  
    --****************************************************************************               
      set @RowCount=0
      select @RowCount=count(id) from #tabla_reporte where tipo = 13 and subtipo=1   
      
      if @RowCount = 8--Cantidad de lineas que ocupa el header(7) y footer(2)
         begin 
         update #tabla_reporte set  visible=0 where tipo =13 and subtipo=1                
         end
 ------------------------------------------------------------------------------------------------ 
 -- RECEPCION DE TOKEN
 ------------------------------------------------------------------------------------------------     

    set @F_Criterio = ''
    set @F_Criterio = 'a.usuario§' + case @I_Usuario when 0 then '' 
                                     else ltrim(str(@I_Usuario))end+'¶'
                     +'a.agencia_usr§'+ case @I_agencia when 0 then '' 
                                     else ltrim(str(@I_agencia))end+'¶'
    exec @F_error_exec=Construct_GLB
                        @I_mostrar    = 'N',
                        @IO_construct = @F_Criterio  output,
                        @O_error_msg  = @O_error_msg output
    IF @@error <> 0 
       BEGIN
       SET @O_error_msg ='Error al ejecutar Construct_GLB.'
       GOTO Error
       END  
				IF @F_error_exec <> 0 GOTO Error    
    insert into #tabla_reporte
    select 13,2,1,linea_texto           = ''
    union all select 13,2,1,Linea_texto = '---------------------------------------------------------------------------------------------------------------------' 
    union all Select 13,2,1,Linea_texto = 'RECEPCIÓN DE TOKEN '
    union all Select 13,2,1,Linea_texto = '---------------------------------------------------------------------------------------------------------------------' 
    union all Select 13,2,1,Linea_texto = '                           Nro.        Código                    Agencia                   Estado           Recibido ' 
    union all Select 13,2,1,Linea_texto = 'Comprobante     Usuario    Token       Serial                    Destino                   Actual                    ' 
    union all Select 13,2,1,Linea_texto = '---------------------------------------------------------------------------------------------------------------------'
    
    --****************************************************************************
   insert into #tabla_reporte 
   exec ('select 13,2,1,linea_texto = cast(a.comprobante  as char(16)) + space(1)+ ' +
                                     ' cast(ISNULL(a.nombcorto,'''') as char(10))+space(1)+  ' +
                                     ' cast(isnull(a.id_token,0) as char(10))+SPACE(1)+ ' +
                                     ' cast(isnull(a.cod_serial,'''') as char(20))+SPACE(1)+ ' +
                                     ' str(isnull(agencia_destino,0),8) + ''-'' + ' +
                                     ' cast(a.desc_agencia_destino as char(15)) + space(3) +' +
                                     ' str(isnull(a.estado,0),5) + ''-'' + '+
                                     ' cast(isnull(a.nomb_estado,'''')as CHAR(15)) + space(2) +' +
                                     ' isnull(a.recibido,'''') ' +
         ' from dbo.fnt_fslnet_MovimientoToken ('+@F_str_fecha + ',' + @F_str_fecha + ' , 2) as a '+                                                   
         ' where ' + @F_Criterio )    
    insert into #tabla_reporte 
    Exec('select 13,2,1,linea_texto = ''Total Operaciones ===>''+STR(count(*)) ' + 
                                       ' from fnt_fslnet_MovimientoToken ('+@F_str_fecha + ',' + @F_str_fecha + ' , 2) as a ' +                                                      
                                       ' where ' + @F_Criterio                                                               
      )  
    --****************************************************************************               
      set @RowCount=0
      select @RowCount=count(id) from #tabla_reporte where tipo = 13 and subtipo=2   
      
      if @RowCount = 8--Cantidad de lineas que ocupa el header(7) y footer(2)
         begin 
         update #tabla_reporte set  visible=0 where tipo =13 and subtipo=2                
         end
 ------------------------------------------------------------------------------------------------ 
 -- TRANSFERENCIA DE TOKEN 
 ------------------------------------------------------------------------------------------------ 
    set @F_Criterio = ''
    set @F_Criterio = 'a.usuario§' + case @I_Usuario when 0 then '' 
                                     else ltrim(str(@I_Usuario))end+'¶'
                     +'a.agencia_usr§'+ case @I_agencia when 0 then '' 
                                     else ltrim(str(@I_agencia))end+'¶'
    exec @F_error_exec=Construct_GLB
                        @I_mostrar    = 'N',
                        @IO_construct = @F_Criterio  output,
                        @O_error_msg  = @O_error_msg output
    IF @@error <> 0 
       BEGIN
       SET @O_error_msg ='Error al ejecutar Construct_GLB.'
       GOTO Error
       END  
				IF @F_error_exec <> 0 GOTO Error    
    insert into #tabla_reporte
    select 13,3,1,linea_texto           = ''
    union all select 13,3,1,Linea_texto = '--------------------------------------------------------------------------------------------------------' 
    union all Select 13,3,1,Linea_texto = 'TRANSFERENCIA DE TOKEN '
    union all Select 13,3,1,Linea_texto = '--------------------------------------------------------------------------------------------------------' 
    union all Select 13,3,1,Linea_texto = '                          Nro.        Código                    Agencia                    Estado       ' 
    union all Select 13,3,1,Linea_texto = 'Comprobante    Usuario    Token       Serial                    Destino                    Actual       ' 
    union all Select 13,3,1,Linea_texto = '--------------------------------------------------------------------------------------------------------'
    
    --****************************************************************************
   insert into #tabla_reporte 
   exec ('select 13,3,1,linea_texto =  cast(a.comprobante  as char(16)) + space(1)+ ' +
                                       ' cast(ISNULL(a.nombcorto,'''') as char(10))+space(1)+  ' +
                                       ' cast(isnull(a.id_token,0) as char(10))+SPACE(1)+ ' +
                                       ' cast(isnull(a.cod_serial,'''') as char(20))+SPACE(1)+ ' +
                                       ' str(isnull(agencia_destino,0),8) + ''-'' + ' +
                                       ' cast(a.desc_agencia_destino as char(15)) + space(3) +' +
                                       ' str(isnull(a.estado,0),5) + ''-'' + '+
                                       ' cast(isnull(a.nomb_estado,'''')as CHAR(20)) '+
          ' from dbo.fnt_fslnet_MovimientoToken ('+@F_str_fecha + ',' + @F_str_fecha + ' , 3) as a '+                                                   
          ' where ' + @F_Criterio )    
    insert into #tabla_reporte 
    Exec('select 13,3,1,linea_texto = ''Total Operaciones ===>''+STR(count(*)) ' + 
                                       ' from fnt_fslnet_MovimientoToken ('+@F_str_fecha + ',' + @F_str_fecha + ' , 3) as a ' +                                                      
                                       ' where ' + @F_Criterio                                                               
      )  
    --****************************************************************************               
      set @RowCount=0
      select @RowCount=count(id) from #tabla_reporte where tipo = 13 and subtipo=3   
      
      if @RowCount = 8--Cantidad de lineas que ocupa el header(7) y footer(2)
         begin 
         update #tabla_reporte set  visible=0 where tipo =13 and subtipo=3                
         end   
  
-- endregion                       
    --xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    --     MOSTRAR REPORTE DINAMICO COMPLETO
    --xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

    Select Linea_texto = linea
    from #tabla_reporte where visible =1 order by ID    
---------------------------------------------------------------------------------------------------
--SALIR DEL PROCEDIMIENTO
---------------------------------------------------------------------------------------------------

linea_salir_procedimiento:
    SET TRANSACTION  ISOLATION LEVEL READ COMMITTED
---------------------------------------------------------------------------------------------------
--  Grabar log
---------------------------------------------------------------------------------------------------
    if (@@nestlevel=1)  and @I_server_origen = 0
       begin
       set @F_observacion_error = 'FechaProceso: '+isnull(convert(char(10),@z_fecha_proceso,105),'Nulo')+
                                  ' Usuario: '+ isnull(cast(@I_Usuario as varchar(16)),'Nulo') +
                                  ' Agencia:' + isnull(cast(@I_agencia as varchar(16)),'Nulo') +
                                  ' Indicador: '+ isnull(rtrim(ltrim(@I_Indicador)),'Nulo')
       exec Grabar_log_GLB
            @I_usuario            = @F_usuario,
            @I_fecha_proceso      = @F_fecha_proceso,
            @I_observacion_error  = @F_observacion_error,
            @I_nombre_sp          = 'Rep_movimientos_cah_dpf_tj_CAP',  --Nombre del procedimiento almacenado
            @I_fecha_desde        = @F_fecha_desde_log,
            @I_tipo_log           = 1,                                 --1=reporte, 2=abm
            @I_es_error           = 0,                                 --0=no es error, 1=si es error
            @I_error_msg          = ''
       end
   return 0
error:
    SET TRANSACTION  ISOLATION LEVEL READ COMMITTED
   SET @O_error_msg='Rep_movimientos_cah_dpf_tj_CAP.§' + isnull(@O_error_msg,'Nulo')
    if (@@nestlevel=1)  and @I_server_origen = 0
       begin
       set @F_observacion_error = 'FechaProceso: '+isnull(convert(char(10),@z_fecha_proceso,105),'Nulo')+
                                  ' Usuario: '+ isnull(cast(@I_Usuario as varchar(16)),'Nulo') +
                                  ' Agencia:' + isnull(cast(@I_agencia as varchar(16)),'Nulo') +
                                  ' Indicador: '+ isnull(rtrim(ltrim(@I_Indicador)),'Nulo')                          
       exec Grabar_log_GLB
            @I_usuario            = @F_usuario,
            @I_fecha_proceso      = @F_fecha_proceso,
            @I_observacion_error  = @F_observacion_error,
            @I_nombre_sp          = 'Rep_movimientos_cah_dpf_tj_CAP',  --Nombre del procedimiento almacenado
            @I_fecha_desde        = @F_fecha_desde_log,
            @I_tipo_log           = 1,                                 --1=reporte, 2=abm
            @I_es_error           = 1,                                 --0=no es error, 1=si es error
            @I_error_msg          = @O_error_msg
       RAISERROR(@O_error_msg,16,-1)
       end
   RETURN -1   
GO
