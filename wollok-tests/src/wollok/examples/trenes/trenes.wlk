class Deposito {
	const formaciones = []
	
	method agregarFormacion(unTren) { formaciones.add(unTren) }
	method vagonesMasPesados() { return formaciones.map { t => t.vagonMasPesado()} }
}

class Tren {
	const vagones = []
	const locomotoras = []
	
	method agregarVagon(v) { vagones.add(v) }
	method getCantidadPasajeros() = vagones.sum{v=> v.getCantidadPasajeros()}
	method getCantidadVagonesLivianos() = vagones.count{v=> v.esLiviano()}
	method getVelocidadMaxima() = locomotoras.min{l=> l.getVelocidadMaxima() }.getVelocidadMaxima()
	method agregarLocomotora(loco) { locomotoras.add(loco)	}
	method esEficiente() = locomotoras.all{l=> l.esEficiente()}
	method puedeMoverse() = self.arrastreUtilTotalLocomotoras() >= self.pesoMaximoTotalDeVagones()
	method arrastreUtilTotalLocomotoras() = locomotoras.sum {l=> l.arrastreUtil() }
	method pesoMaximoTotalDeVagones() = vagones.sum{v=> v.getPesoMaximo()}
	method getKilosEmpujeFaltantes() =
		if (self.puedeMoverse())
			0
		else
			self.pesoMaximoTotalDeVagones() - self.arrastreUtilTotalLocomotoras()
	method vagonMasPesado() = vagones.max({v=> v.getPesoMaximo() })
}

class Locomotora {
	var peso
	var pesoMaximoArrastre
	var velocidadMaxima
	method getVelocidadMaxima() = velocidadMaxima 
	
	method esEficiente() = pesoMaximoArrastre >= 5 * peso
	method arrastreUtil() = pesoMaximoArrastre - peso
}

class Vagon {
	method esLiviano() = self.getPesoMaximo() < 2500
	method getCantidadPasajeros() 
	method getPesoMaximo()
}

class VagonPasajeros inherits Vagon {
	var ancho
	var largo
	
	override method getCantidadPasajeros() {
		return largo * if (ancho < 2.5) 8 else 10
	}
	override method getPesoMaximo() {
		return self.getCantidadPasajeros() * 80
	}
}

class VagonCarga inherits Vagon {
	var cargaMaxima
	override method getCantidadPasajeros() = 0
	override method getPesoMaximo() = cargaMaxima + 160
}

