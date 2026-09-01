class DatePerson {
  String uid;
  String name;
  String? profile; // Permitir nulos
  String? cover; // Permitir nulos
  String? status; // Permitir nulos
  String? search; // Permitir nulos
  String? facebook; // Permitir nulos
  String? instagram; // Permitir nulos
  DateTime birthdate;
  String program;

  DatePerson({
    required this.uid,
    required this.name,
    this.profile, // Opcional
    this.cover, // Opcional
    this.status, // Opcional
    this.search, // Opcional
    this.facebook, // Opcional
    this.instagram, // Opcional
    required this.birthdate,
    required this.program,
  });

  // Método para crear una instancia de DatePerson desde un JSON
  factory DatePerson.fromJson(Map<String, dynamic> json) {
    return DatePerson(
      uid: json['uid'],
      name: json['name'],
      profile: json['profile'] ?? '', // Asignar valor por defecto si es null
      cover: json['cover'] ?? '', // Asignar valor por defecto si es null
      status: json['status'] ?? '', // Asignar valor por defecto si es null
      search: json['search'] ?? '', // Asignar valor por defecto si es null
      facebook: json['facebook'] ?? '', // Asignar valor por defecto si es null
      instagram:
          json['instagram'] ?? '', // Asignar valor por defecto si es null
      birthdate:
          DateTime.parse(json['birthdate']), // Convierte el string a DateTime
      program: json['program'],
    );
  }

  // Método para convertir una instancia de DatePerson a JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'profile': profile ?? '', // Asegúrate de no devolver null
      'cover': cover ?? '',
      'status': status ?? '',
      'search': search ?? '',
      'facebook': facebook ?? '',
      'instagram': instagram ?? '',
      'birthdate':
          birthdate.toIso8601String(), // Convierte DateTime a string ISO 8601
      'program': program,
    };
  }
}
