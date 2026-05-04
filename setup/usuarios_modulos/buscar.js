	function cortar()
	{
		var texto1 = document.datos1.f_buscar_1.value.toUpperCase();
		var texto2 = document.datos1.f_buscar_2.value.toUpperCase();
		var texto3 = document.datos1.f_buscar_3.value.toUpperCase();
		if((texto1=="")&&(texto2=="")&&(texto3==""))
		{
			alert("Complete formulario");
			return true;
		}else{
			document.datos1.submit();
		}	
	}
