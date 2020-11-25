--Esta es una prueba de cambios
declare @nombre_sp varchar(100) = 'calculo_interes_CAR',--proc_repgir_formulario_mensual
        @nombre_sp1 varchar(100) = '',
        @nombre_opcion varchar(100)='               ',
        @sistema int=0,
        @detallado tinyint =1,
        @detallado_dep tinyint  =0,
        @log_ant tinyint  =0

								  -- Proc_repCCT_cambio_estado
--  proc_abmcont_GenerarArchBalance
select @nombre_opcion= ltrim(rtrim(descripcion)) +' ' + substring(uriweb,1,10) , @sistema =sistema  ,@nombre_sp1=nombre_sp
   from pam_sps_header /*,
        Prueba.dbo.pamseg_agrupacion a,
        Prueba.dbo.pamseg_modulo m */
where nombre_sp like @nombre_sp --+'%'	
   and fecha_proceso_hasta = '01-01-2050'
--where nombre_sp like @nombre_sp +'%' and fecha_proceso_hasta = '01-01-2050'
--print  @nombre_opcion + 'sistema: '+ str(@sistema)
select nombre_opcion= ltrim(rtrim(descripcion)) +' ' + substring(uriweb,1,10) --, @sistema =sistema  ,@nombre_sp1=nombre_sp
   from pam_sps_header /*,
        Prueba.dbo.pamseg_agrupacion a,
        Prueba.dbo.pamseg_modulo m */
where nombre_sp like @nombre_sp +'%' and fecha_proceso_hasta = '01-01-2050'
select 'Opcion: '+ @nombre_opcion + ' Sistema: '+ str(@sistema) +' Sp: '+ @nombre_sp1

--if @detallado_dep =1 
--begin
----select referencing_entity_name 
--  --       from sys.dm_sql_referencing_entities (@nombre_sp, 'OBJECT');

--exec  sp_depends @nombre_sp
--end
---- para pam_log2
if @log_ant = 1
begin
---- maximo log de pam_log 237081810  de fecha 2018-12-05 11:07:18.007
select * from pam_log 
    where nro_log >  1068323  -- and  110683233 --> 125243790 and --  rep_factura_terceros
    and  nombre_sp like'%'+@nombre_sp+'%' 
 --   and glosa like '%772%'
order by nro_log
end
if @detallado =1 
begin
select * from pam_log2 
    where nro_log > 74794657 -- 22641686  -- and  110683233 --> 125243790 and --  rep_factura_terceros
    and  nombre_sp like'%'+@nombre_sp+'%' 
 --   and glosa like '%772%'
order by nro_log
end
