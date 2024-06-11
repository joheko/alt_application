class AsaExposure {
  int? id;
  String date;
  String duration; //Keston tallennus muodossa h:mm
  String notes;

  AsaExposure({
    this.id,
    required this.date,
    required this.duration,
    required this.notes,
  });

  // Muuntaa olion kartaksi tietokantaa varten
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'date': date,
      'duration': duration,
      'notes': notes,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  // Luo olion kartasta, joka on saatu tietokannasta
  factory AsaExposure.fromMap(Map<String, dynamic> map) {
    return AsaExposure(
      id: map['id'],
      date: map['date'],
      duration: map['duration'],
      notes: map['notes'],
    );
  }
  
}
