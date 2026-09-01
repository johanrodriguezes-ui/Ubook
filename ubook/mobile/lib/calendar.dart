import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:ubook/services/calendarservice.dart';
import 'package:ubook/services/auth_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, List<Map<String, dynamic>>> _events = {};
  final List<Map<String, dynamic>> _allReminders = [];
  final AuthService authService = AuthService();

  String? userId;
  String _viewOption = 'Por día';

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    String? savedUserId = await authService.getUserId();
    if (savedUserId != null) {
      setState(() {
        userId = savedUserId;
      });
      _loadReminders();
    } else {
      print('No se encontró el userId');
    }
  }

  Future<void> _loadReminders() async {
    if (userId != null) {
      try {
        List<dynamic> reminders =
            await CalendarService.loadReminders(int.parse(userId!));

        setState(() {
          _allReminders.clear();
          _events.clear(); // Reset the events

          // Populate the _events map with reminders
          for (var reminder in reminders) {
            DateTime date = DateTime.parse(
                reminder['reminder_date']); // Ensure accurate parsing of date
            if (_events[date] == null) {
              _events[date] = [];
            }

            // Add reminder to the _events map and the list of all reminders
            _events[date]!.add({
              'message': reminder['reminder_message'],
              'reminder_id': reminder['reminder_id'],
            });

            _allReminders.add({
              'date': date,
              'message': reminder['reminder_message'],
              'reminder_id': reminder['reminder_id'],
            });
          }
        });
      } catch (e) {
        print('Error loading reminders: $e');
      }
    }
  }

  Future<void> _loadRemindersByDay(DateTime day) async {
    if (userId != null) {
      try {
        List<dynamic> reminders = await CalendarService.getRemindersByDay(
            int.parse(userId!), day.toIso8601String().split('T')[0]);

        setState(() {
          _events[day]
              ?.clear(); // Limpiamos solo los eventos del día seleccionado
          _events[day] = [];

          for (var reminder in reminders) {
            _events[day]!.add({
              'message': reminder['reminder_message'],
              'reminder_id': reminder['reminder_id'],
            });
          }
        });
      } catch (e) {
        print('Error al cargar recordatorios para este día: $e');
      }
    }
  }

  void _addReminder(DateTime day) {
    String reminderText = '';
    String? errorMessage; // Para mostrar el mensaje de error si es necesario

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Añadir Recordatorio'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        reminderText = value;
                        errorMessage =
                            null; // Resetear el mensaje de error si se introduce texto
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Escribe tu recordatorio",
                      errorText:
                          errorMessage, // Mostrar el mensaje de error si existe
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cerrar diálogo
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (reminderText.isEmpty) {
                      setState(() {
                        errorMessage = 'El recordatorio no puede estar vacío';
                      });
                    } else if (userId != null) {
                      try {
                        // Añadir el recordatorio a través del servicio
                        await CalendarService.addReminder(
                          int.parse(userId!),
                          reminderText,
                          day.toIso8601String(),
                        );
                        await _loadReminders(); // Recargar los recordatorios
                        Navigator.of(context).pop(); // Cerrar diálogo
                      } catch (e) {
                        print('Error añadiendo recordatorio: $e');
                      }
                    }
                  },
                  child: const Text('Añadir'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editReminder(DateTime day, String reminderId) {
    final reminder = _events[day]?.firstWhere(
      (event) => event['reminder_id'].toString() == reminderId,
      orElse: () => <String, dynamic>{}, // Mapa vacío en lugar de null
    );

    // Verificamos si el recordatorio no es null y no está vacío
    if (reminder != null && reminder.isNotEmpty) {
      String updatedText = reminder['message'] ?? '';
      String? errorMessage; // Para mostrar el mensaje de error si es necesario

      // Mover la creación del controlador afuera del builder
      final TextEditingController textController =
          TextEditingController(text: updatedText);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Editar Recordatorio'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller:
                          textController, // Usar el controlador existente
                      onChanged: (value) {
                        setState(() {
                          updatedText = value;
                          errorMessage =
                              null; // Resetear el mensaje de error si cambia el texto
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Editar recordatorio",
                        errorText:
                            errorMessage, // Mostrar el mensaje de error si existe
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Cerrar diálogo
                    },
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (updatedText.isEmpty) {
                        setState(() {
                          errorMessage = 'El recordatorio no puede estar vacío';
                        });
                      } else {
                        try {
                          // Editar el recordatorio a través del servicio
                          await CalendarService.editReminder(
                            int.parse(reminderId),
                            updatedText,
                            day.toIso8601String(),
                          );
                          await _loadReminders(); // Recargar los recordatorios
                          Navigator.of(context).pop(); // Cerrar diálogo
                        } catch (e) {
                          print('Error editando recordatorio: $e');
                        }
                      }
                    },
                    child: const Text('Guardar'),
                  ),
                ],
              );
            },
          );
        },
      );
    } else {
      print('Recordatorio no encontrado.');
    }
  }

  void _deleteReminder(DateTime day, String reminderId) async {
    final reminder = _events[day]?.firstWhere(
      (event) => event['reminder_id'].toString() == reminderId,
      orElse: () => <String, dynamic>{}, // Mapa vacío en lugar de null
    );

    if (reminder != null) {
      // Mostrar diálogo de confirmación
      bool? confirmDelete = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: const Text(
                '¿Está seguro de que desea eliminar este recordatorio?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // Usuario selecciona "No"
                },
                child: const Text('No'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // Usuario selecciona "Sí"
                },
                child: const Text('Sí'),
              ),
            ],
          );
        },
      );

      // Si el usuario confirmó, proceder con la eliminación
      if (confirmDelete == true) {
        try {
          await CalendarService.deleteReminder(int.parse(reminderId));
          await _loadReminders(); // Volver a sincronizar después de eliminar
        } catch (e) {
          print('Error eliminando recordatorio: $e');
        }
      }
    } else {
      print('Recordatorio no encontrado.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF004D40), // Verde oscuro
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });

              if (_viewOption == 'Por día') {
                _loadRemindersByDay(selectedDay); // Solo afecta a la lista
              }
            },
            eventLoader: (day) {
              // Filtrar eventos basados en el reminder_date
              return _allReminders.where((reminder) {
                DateTime reminderDate = DateTime(reminder['date'].year,
                    reminder['date'].month, reminder['date'].day);
                return isSameDay(
                    reminderDate, day); // Comparación precisa por fecha
              }).toList();
            },
            calendarFormat: CalendarFormat.month, // Fijar a vista mensual
            availableCalendarFormats: const {
              CalendarFormat.month: 'Mes', // Solo opción mensual disponible
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _viewOption,
              items: const [
                DropdownMenuItem(
                    value: 'Por día', child: Text('Recordatorios por día')),
                DropdownMenuItem(
                    value: 'Todos', child: Text('Todos los recordatorios')),
              ],
              onChanged: (value) {
                setState(() {
                  _viewOption = value!;
                });
              },
            ),
          ),
          Expanded(
            child: _viewOption == 'Por día'
                ? _selectedDay != null
                    ? (_events[_selectedDay]?.isNotEmpty ?? false)
                        ? ListView.builder(
                            itemCount: _events[_selectedDay]?.length ?? 0,
                            itemBuilder: (context, index) {
                              final reminder = _events[_selectedDay]![index];
                              return ListTile(
                                title: Text(reminder['message']),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        _editReminder(_selectedDay!,
                                            reminder['reminder_id'].toString());
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        _deleteReminder(_selectedDay!,
                                            reminder['reminder_id'].toString());
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Text("No hay recordatorios para este día."))
                    : const Center(
                        child: Text(
                            "Selecciona un día para ver los recordatorios."))
                : ListView.builder(
                    itemCount: _allReminders.length,
                    itemBuilder: (context, index) {
                      final reminder = _allReminders[index];
                      return ListTile(
                        title: Text(reminder['message']),
                        subtitle: Text(
                            'Fecha: ${reminder['date'].toString().split(' ')[0]}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _editReminder(reminder['date'],
                                    reminder['reminder_id'].toString());
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                _deleteReminder(reminder['date'],
                                    reminder['reminder_id'].toString());
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedDay != null) {
            _addReminder(_selectedDay!);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
