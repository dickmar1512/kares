		function selecionatodo()
		{
			var total_items = document.datos.f_contador.value;
			
			if(document.datos.chktodas.checked ) // para chequear
			{
				for(i=1; i<=total_items; i++)
				{
					eval("document.datos.chk_"+i+".checked=true;");
				}
				document.datos.chequeados.value=total_items;
			}

			if(!document.datos.chktodas.checked ) //Para deschequear
			{
				for(i=1; i<=total_items; i++)
				{
					eval("document.datos.chk_"+i+".checked=false;");
				}
				document.datos.chequeados.value='0';
			}

		}

		
		function check_uno(i)
		{
			var total_items 	= document.datos.f_contador.value;
			var cant_chequeados 	= document.datos.chequeados.value;
			
			if( eval("document.datos.chk_"+i+".checked==true;") )
			{
				cant_chequeados = parseInt(cant_chequeados)+1;
			}else{
				cant_chequeados = parseInt(cant_chequeados)-1;
			}
						
			if ( eval(cant_chequeados) ==total_items)
			{
				document.datos.chktodas.checked=true;
			}else{
				document.datos.chktodas.checked=false;
			}
						
			document.datos.chequeados.value=cant_chequeados;
		}


		