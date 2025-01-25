class CalendarUtils {
  static ultimostresMesesPorExtenso() {
    var meses = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro'
    ];
    var data = DateTime.now();
    var mesAtual = data.month;
    var anoAtual = data.year;
    var mesesPorExtenso = [];
    for (var i = 0; i < 3; i++) {
      if (mesAtual - i < 1) {
        mesesPorExtenso.add('${meses[mesAtual - i + 12]} de ${anoAtual - 1}');
      } else {
        mesesPorExtenso.add('${meses[mesAtual - i - 1]} de $anoAtual');
      }
    }
    return mesesPorExtenso;
  }

  static getMesAnterior(int i) {
    var data = DateTime.now();
    var mesAtual = data.month;
    if (mesAtual - i < 1) {
      return mesAtual - i + 12;
    } else {
      return mesAtual - i;
    }
  }
}
