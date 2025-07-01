import 'package:flutter/material.dart';
import '../models/social_post.dart';
import '../services/social_weather_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/weather_challenge.dart';
import '../models/weather_comparison.dart';

class SocialFeedScreen extends StatefulWidget {
  const SocialFeedScreen({super.key});

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen> {
  final SocialWeatherService _socialService = SocialWeatherService();
  late Future<List<SocialPost>> _feedFuture;
  late Future<List<WeatherChallenge>> _challengesFuture;

  @override
  void initState() {
    super.initState();
    _feedFuture = Future.value(_socialService.getAllPosts());
    _challengesFuture = Future.value(_socialService.getAllChallenges());
  }

  Future<void> _refreshFeed() async {
    setState(() {
      _feedFuture = Future.value(_socialService.getAllPosts());
      _challengesFuture = Future.value(_socialService.getAllChallenges());
    });
  }

  Future<void> _showCreatePostDialog() async {
    final TextEditingController messageController = TextEditingController();
    File? imageFile;
    bool isLoading = false;
    
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Nouvelle publication météo'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: messageController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Votre message',
                        hintText: 'Décrivez la météo ou partagez votre ressenti...'
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (imageFile != null)
                      Image.file(imageFile!, height: 100),
                    TextButton.icon(
                      icon: const Icon(Icons.image),
                      label: const Text('Ajouter une image'),
                      onPressed: () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(source: ImageSource.gallery);
                        if (picked != null) {
                          setState(() {
                            imageFile = File(picked.path);
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    setState(() => isLoading = true);
                    await _socialService.createPost(
                      message: messageController.text,
                      location: 'Paris',
                      imagePath: imageFile?.path,
                    );
                    setState(() => isLoading = false);
                    Navigator.pop(context);
                    _refreshFeed();
                  },
                  child: isLoading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Publier'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showShareDialog(SocialPost post) async {
    final List<String> platforms = [
      'twitter', 'facebook', 'instagram', 'whatsapp', 'telegram', 'linkedin', 'discord'
    ];
    final Map<String, bool> selected = {for (var p in platforms) p: false};
    bool isLoading = false;
    String? resultMessage;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Partager sur les réseaux sociaux'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...platforms.map((p) => CheckboxListTile(
                        value: selected[p],
                        onChanged: (v) => setState(() => selected[p] = v ?? false),
                        title: Text(p[0].toUpperCase() + p.substring(1)),
                      )),
                  if (resultMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(resultMessage!, style: const TextStyle(color: Colors.green)),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() => isLoading = true);
                          final chosen = selected.entries.where((e) => e.value).map((e) => e.key).toList();
                          if (chosen.isEmpty) {
                            setState(() {
                              resultMessage = 'Veuillez sélectionner au moins une plateforme.';
                              isLoading = false;
                            });
                            return;
                          }
                          final success = await _socialService.shareToSocialMedia(post, chosen.first);
                          setState(() {
                            resultMessage = success
                                ? 'Publication partagée avec succès !'
                                : 'Erreur lors du partage.';
                            isLoading = false;
                          });
                          if (success) {
                            await Future.delayed(const Duration(seconds: 1));
                            Navigator.pop(context);
                          }
                        },
                  child: isLoading
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Partager'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showChallengeDialog() async {
    final List<String> challengeTypes = [
      'Prédiction de température',
      'Photo météo',
      'Exploration de lieu',
      'Streak météo',
    ];
    String selectedType = challengeTypes[0];
    final TextEditingController descriptionController = TextEditingController();
    bool isLoading = false;
    String? resultMessage;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Lancer un défi météo'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    items: challengeTypes.map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    )).toList(),
                    onChanged: (v) => setState(() => selectedType = v ?? challengeTypes[0]),
                    decoration: const InputDecoration(labelText: 'Type de défi'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Description du défi',
                      hintText: 'Ex : Prédisez la température de demain à Paris...'
                    ),
                  ),
                  if (resultMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(resultMessage!, style: const TextStyle(color: Colors.green)),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    setState(() => isLoading = true);
                    final challenge = await _socialService.createWeatherChallenge(
                      title: 'Défi météo',
                      description: descriptionController.text,
                      type: ChallengeType.weatherPhoto,
                      endDate: DateTime.now().add(const Duration(days: 7)),
                    );
                    setState(() {
                      resultMessage = challenge != null
                        ? 'Défi lancé avec succès !'
                        : 'Erreur lors de la création du défi.';
                      isLoading = false;
                    });
                    if (challenge != null) {
                      await Future.delayed(const Duration(seconds: 1));
                      Navigator.pop(context);
                    }
                  },
                  child: isLoading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Lancer le défi'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showCommentDialog(SocialPost post) async {
    final TextEditingController commentController = TextEditingController();
    bool isLoading = false;
    String? resultMessage;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Ajouter un commentaire'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Votre commentaire',
                      hintText: 'Partagez votre avis sur cette météo...'
                    ),
                  ),
                  if (resultMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(resultMessage!, style: const TextStyle(color: Colors.green)),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    setState(() => isLoading = true);
                    // Simuler l'ajout d'un commentaire
                    await Future.delayed(const Duration(milliseconds: 500));
                    setState(() {
                      resultMessage = 'Commentaire ajouté !';
                      isLoading = false;
                    });
                    await Future.delayed(const Duration(seconds: 1));
                    Navigator.pop(context);
                    _refreshFeed();
                  },
                  child: isLoading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Commenter'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showReactionDialog(SocialPost post) async {
    final List<String> reactions = ['☀️', '🌧️', '❄️', '⛈️', '🌫️', '😊', '😍', '👍'];
    String? selectedReaction;
    bool isLoading = false;
    String? resultMessage;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Réagir à cette météo'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: reactions.map((emoji) => GestureDetector(
                      onTap: () => setState(() => selectedReaction = emoji),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selectedReaction == emoji ? Colors.blue : Colors.grey,
                            width: selectedReaction == emoji ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(emoji, style: const TextStyle(fontSize: 24)),
                      ),
                    )).toList(),
                  ),
                  if (resultMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(resultMessage!, style: const TextStyle(color: Colors.green)),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: isLoading || selectedReaction == null ? null : () async {
                    setState(() => isLoading = true);
                    // Simuler l'ajout d'une réaction
                    await Future.delayed(const Duration(milliseconds: 500));
                    setState(() {
                      resultMessage = 'Réaction ajoutée !';
                      isLoading = false;
                    });
                    await Future.delayed(const Duration(seconds: 1));
                    Navigator.pop(context);
                    _refreshFeed();
                  },
                  child: isLoading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Réagir'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showChallengeDetailsDialog(Map<String, dynamic> challenge) async {
    final List<Map<String, dynamic>> participants = [
      {'name': 'Alice', 'score': 85, 'status': 'En cours'},
      {'name': 'Bob', 'score': 92, 'status': 'Terminé'},
      {'name': 'Charlie', 'score': 78, 'status': 'En cours'},
    ];
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Détails du défi : ${challenge['type']}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Description : ${challenge['description']}'),
                  const SizedBox(height: 8),
                  Text('Lieu : ${challenge['location']}'),
                  const SizedBox(height: 8),
                  Text('Participants : ${challenge['participants']?.length ?? 0}'),
                  const SizedBox(height: 16),
                  const Text('Classement', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...participants.asMap().entries.map((entry) {
                    final i = entry.key;
                    final p = entry.value;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: i == 0 ? Colors.amber : i == 1 ? Colors.grey : Colors.brown,
                        child: Text('${i + 1}', style: const TextStyle(color: Colors.white)),
                      ),
                      title: Text(p['name']),
                      subtitle: Text('Score : ${p['score']}'),
                      trailing: Chip(
                        label: Text(p['status']),
                        backgroundColor: p['status'] == 'Terminé' ? Colors.green.shade50 : Colors.orange.shade50,
                      ),
                    );
                  }),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fermer'),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    setState(() => isLoading = true);
                    // Simuler la soumission d'une réponse
                    await Future.delayed(const Duration(milliseconds: 1000));
                    setState(() => isLoading = false);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Réponse soumise avec succès !')),
                    );
                  },
                  child: isLoading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Soumettre ma réponse'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showWeatherComparisonDialog() async {
    final TextEditingController city1Controller = TextEditingController();
    final TextEditingController city2Controller = TextEditingController();
    bool isLoading = false;
    WeatherComparison? comparisonData;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Comparatif météo'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: city1Controller,
                    decoration: const InputDecoration(
                      labelText: 'Ville 1',
                      hintText: 'Ex : Paris'
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: city2Controller,
                    decoration: const InputDecoration(
                      labelText: 'Ville 2',
                      hintText: 'Ex : Londres'
                    ),
                  ),
                  if (comparisonData != null) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(comparisonData?.city1 ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text('${comparisonData?.weather1.temperature ?? 0}°C'),
                              Text(comparisonData?.weather1.description ?? 'N/A'),
                              Text('Humidité : ${comparisonData?.weather1.humidity ?? 0}%'),
                            ],
                          ),
                        ),
                        const VerticalDivider(),
                        Expanded(
                          child: Column(
                            children: [
                              Text(comparisonData?.city2 ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text('${comparisonData?.weather2.temperature ?? 0}°C'),
                              Text(comparisonData?.weather2.description ?? 'N/A'),
                              Text('Humidité : ${comparisonData?.weather2.humidity ?? 0}%'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text('Différence de température : ${comparisonData?.temperatureDiff ?? 0}°C'),
                          Text('Différence d\'humidité : ${comparisonData?.humidityDiff ?? 0}%'),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    if (city1Controller.text.isEmpty || city2Controller.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Veuillez saisir deux villes')),
                      );
                      return;
                    }
                    setState(() => isLoading = true);
                    try {
                      final comparison = await _socialService.getWeatherComparison('Paris', 'Lyon');
                      setState(() {
                        comparisonData = comparison;
                        isLoading = false;
                      });
                    } catch (e) {
                      setState(() => isLoading = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Erreur lors de la comparaison')),
                      );
                    }
                  },
                  child: isLoading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Comparer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showCustomAlertsDialog() async {
    final List<Map<String, dynamic>> alerts = [
      {'type': 'temp_high', 'condition': 'Température > 30°C', 'enabled': true},
      {'type': 'temp_low', 'condition': 'Température < 0°C', 'enabled': true},
      {'type': 'rain', 'condition': 'Pluie détectée', 'enabled': false},
      {'type': 'storm', 'condition': 'Orage prévu', 'enabled': true},
    ];
    bool isLoading = false;
    String? resultMessage;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Alertes météo personnalisées'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Configurez vos alertes pour être notifié des changements météo importants.'),
                  const SizedBox(height: 16),
                  ...alerts.map((alert) => SwitchListTile(
                    title: Text(alert['condition']),
                    subtitle: Text(_getAlertDescription(alert['type'])),
                    value: alert['enabled'],
                    onChanged: (value) {
                      setState(() {
                        alert['enabled'] = value;
                      });
                    },
                  )),
                  const SizedBox(height: 16),
                  const Text('Nouvelles alertes', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add_alert_rounded),
                    label: const Text('Ajouter une alerte personnalisée'),
                    onPressed: () {
                      // TODO: Ouvrir dialogue d'ajout d'alerte personnalisée
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fonctionnalité à venir')),
                      );
                    },
                  ),
                  if (resultMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(resultMessage!, style: const TextStyle(color: Colors.green)),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    setState(() => isLoading = true);
                    // Simuler la sauvegarde des alertes
                    await Future.delayed(const Duration(milliseconds: 1000));
                    setState(() {
                      resultMessage = 'Alertes sauvegardées !';
                      isLoading = false;
                    });
                    await Future.delayed(const Duration(seconds: 1));
                    Navigator.pop(context);
                  },
                  child: isLoading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Sauvegarder'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _getAlertDescription(String type) {
    switch (type) {
      case 'temp_high':
        return 'Recevez une notification quand la température dépasse 30°C';
      case 'temp_low':
        return 'Recevez une notification quand la température descend sous 0°C';
      case 'rain':
        return 'Soyez averti avant l\'arrivée de la pluie';
      case 'storm':
        return 'Alertes pour les orages et tempêtes';
      default:
        return 'Alerte personnalisée';
    }
  }

  Future<void> _showTravelModeDialog() async {
    final List<Map<String, dynamic>> tripCities = [
      {'name': 'Paris', 'date': '2024-01-15', 'weather': 'Ensoleillé, 18°C'},
      {'name': 'Lyon', 'date': '2024-01-16', 'weather': 'Nuageux, 15°C'},
      {'name': 'Marseille', 'date': '2024-01-17', 'weather': 'Pluvieux, 12°C'},
    ];
    final TextEditingController newCityController = TextEditingController();
    bool isLoading = false;
    String? resultMessage;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Mode Voyage - Planification météo'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Planifiez votre voyage en fonction de la météo prévue.'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: newCityController,
                          decoration: const InputDecoration(
                            labelText: 'Nouvelle ville',
                            hintText: 'Ex : Nice'
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add_location_rounded),
                        label: const Text('Ajouter'),
                        onPressed: () {
                          if (newCityController.text.isNotEmpty) {
                            setState(() {
                              tripCities.add({
                                'name': newCityController.text,
                                'date': '2024-01-18',
                                'weather': 'À vérifier',
                              });
                            });
                            newCityController.clear();
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Itinéraire prévu', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...tripCities.asMap().entries.map((entry) {
                    final i = entry.key;
                    final city = entry.value;
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Text('${i + 1}'),
                        ),
                        title: Text(city['name']),
                        subtitle: Text('${city['date']} - ${city['weather']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_rounded),
                          onPressed: () {
                            setState(() {
                              tripCities.removeAt(i);
                            });
                          },
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Text('Conseils de voyage', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text('• Prévoir des vêtements adaptés à la pluie à Marseille'),
                        const Text('• Conditions idéales pour visiter Paris et Lyon'),
                        const Text('• Vérifier les prévisions avant le départ'),
                      ],
                    ),
                  ),
                  if (resultMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(resultMessage!, style: const TextStyle(color: Colors.green)),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    setState(() => isLoading = true);
                    // Simuler la sauvegarde du voyage
                    await Future.delayed(const Duration(milliseconds: 1000));
                    setState(() {
                      resultMessage = 'Voyage planifié !';
                      isLoading = false;
                    });
                    await Future.delayed(const Duration(seconds: 1));
                    Navigator.pop(context);
                  },
                  child: isLoading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Planifier le voyage'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showAdvancedForecastDialog() async {
    final List<Map<String, dynamic>> pollenData = [
      {'day': 'Aujourd\'hui', 'level': 'Élevé', 'type': 'Graminées', 'color': Colors.red},
      {'day': 'Demain', 'level': 'Modéré', 'type': 'Graminées', 'color': Colors.orange},
      {'day': 'Après-demain', 'level': 'Faible', 'type': 'Graminées', 'color': Colors.green},
    ];
    final List<Map<String, dynamic>> uvData = [
      {'day': 'Aujourd\'hui', 'index': 8, 'level': 'Très élevé', 'color': Colors.purple},
      {'day': 'Demain', 'index': 6, 'level': 'Élevé', 'color': Colors.orange},
      {'day': 'Après-demain', 'index': 4, 'level': 'Modéré', 'color': Colors.yellow},
    ];
    final List<Map<String, dynamic>> airQualityData = [
      {'day': 'Aujourd\'hui', 'index': 45, 'level': 'Bon', 'color': Colors.green},
      {'day': 'Demain', 'index': 65, 'level': 'Modéré', 'color': Colors.yellow},
      {'day': 'Après-demain', 'index': 35, 'level': 'Bon', 'color': Colors.green},
    ];

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Prévisions avancées'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildForecastSection('Pollen', pollenData, Icons.local_florist_rounded),
                const SizedBox(height: 16),
                _buildForecastSection('Indice UV', uvData, Icons.wb_sunny_rounded),
                const SizedBox(height: 16),
                _buildForecastSection('Qualité de l\'air', airQualityData, Icons.air_rounded),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Text('Conseils santé', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('• Évitez les activités extérieures en cas de pollen élevé'),
                      const Text('• Protégez-vous du soleil (UV très élevé)'),
                      const Text('• Qualité de l\'air bonne pour les activités extérieures'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Ouvrir les détails complets
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Détails complets à venir')),
                );
              },
              child: const Text('Voir plus'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildForecastSection(String title, List<Map<String, dynamic>> data, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        ...data.map((item) => Card(
          child: ListTile(
            title: Text(item['day']),
            subtitle: Text(item['type'] ?? ''),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: item['color'].withAlpha(51),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item['level'] ?? '${item['index']}',
                style: TextStyle(
                  color: item['color'],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        )),
      ],
    );
  }

  Future<void> _showIoTIntegrationDialog() async {
    final List<Map<String, dynamic>> connectedDevices = [
      {'name': 'Thermostat Nest', 'type': 'thermostat', 'status': 'Connecté', 'data': '22°C'},
      {'name': 'Capteur météo Netatmo', 'type': 'weather_sensor', 'status': 'Connecté', 'data': '18°C, 65%'},
      {'name': 'Capteur de qualité d\'air', 'type': 'air_sensor', 'status': 'En attente', 'data': '--'},
    ];
    final List<Map<String, dynamic>> availableDevices = [
      {'name': 'Thermostat Ecobee', 'type': 'thermostat', 'brand': 'Ecobee'},
      {'name': 'Station météo Davis', 'type': 'weather_station', 'brand': 'Davis'},
      {'name': 'Capteur de pollen', 'type': 'pollen_sensor', 'brand': 'PurpleAir'},
    ];
    bool isLoading = false;
    String? resultMessage;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Intégration IoT - Météo hyperlocale'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Connectez vos appareils intelligents pour une météo précise et personnalisée.'),
                    const SizedBox(height: 16),
                    const Text('Appareils connectés', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...connectedDevices.map((device) => Card(
                      child: ListTile(
                        leading: Icon(_getDeviceIcon(device['type']), color: Colors.blue),
                        title: Text(device['name']),
                        subtitle: Text(device['data']),
                        trailing: Chip(
                          label: Text(device['status']),
                          backgroundColor: device['status'] == 'Connecté' ? Colors.green.shade50 : Colors.orange.shade50,
                        ),
                      ),
                    )),
                    const SizedBox(height: 16),
                    const Text('Appareils disponibles', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...availableDevices.map((device) => Card(
                      child: ListTile(
                        leading: Icon(_getDeviceIcon(device['type']), color: Colors.grey),
                        title: Text(device['name']),
                        subtitle: Text(device['brand']),
                        trailing: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              connectedDevices.add({
                                'name': device['name'],
                                'type': device['type'],
                                'status': 'En cours de connexion...',
                                'data': '--',
                              });
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Connexion à ${device['name']} en cours...')),
                            );
                          },
                          child: const Text('Connecter'),
                        ),
                      ),
                    )),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const Text('Avantages IoT', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Text('• Météo ultra-précise à votre domicile'),
                          const Text('• Contrôle automatique du chauffage'),
                          const Text('• Alertes personnalisées basées sur vos capteurs'),
                        ],
                      ),
                    ),
                    if (resultMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(resultMessage!, style: const TextStyle(color: Colors.green)),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fermer'),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    setState(() => isLoading = true);
                    // Simuler la synchronisation IoT
                    await Future.delayed(const Duration(milliseconds: 1500));
                    setState(() {
                      resultMessage = 'Appareils synchronisés !';
                      isLoading = false;
                    });
                    await Future.delayed(const Duration(seconds: 1));
                    Navigator.pop(context);
                  },
                  child: isLoading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Synchroniser'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  IconData _getDeviceIcon(String type) {
    switch (type) {
      case 'thermostat':
        return Icons.thermostat_rounded;
      case 'weather_sensor':
      case 'weather_station':
        return Icons.device_thermostat_rounded;
      case 'air_sensor':
        return Icons.air_rounded;
      case 'pollen_sensor':
        return Icons.local_florist_rounded;
      default:
        return Icons.devices_rounded;
    }
  }

  Future<void> _showNotificationsDialog() async {
    final List<Map<String, dynamic>> notificationTypes = [
      {'type': 'challenges', 'title': 'Défis météo', 'description': 'Nouveaux défis et résultats', 'enabled': true},
      {'type': 'weather_alerts', 'title': 'Alertes météo', 'description': 'Conditions météo importantes', 'enabled': true},
      {'type': 'social_posts', 'title': 'Publications sociales', 'description': 'Posts de vos amis', 'enabled': false},
      {'type': 'achievements', 'title': 'Succès et badges', 'description': 'Nouveaux succès débloqués', 'enabled': true},
      {'type': 'iot_alerts', 'title': 'Alertes IoT', 'description': 'Données de vos capteurs', 'enabled': true},
    ];
    bool isLoading = false;
    String? resultMessage;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Configuration des notifications'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Personnalisez vos notifications pour rester informé.'),
                  const SizedBox(height: 16),
                  ...notificationTypes.map((notification) => SwitchListTile(
                    title: Text(notification['title']),
                    subtitle: Text(notification['description']),
                    value: notification['enabled'],
                    onChanged: (value) {
                      setState(() {
                        notification['enabled'] = value;
                      });
                    },
                  )),
                  const SizedBox(height: 16),
                  const Text('Préférences avancées', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const ListTile(
                    leading: Icon(Icons.schedule_rounded),
                    title: Text('Fréquence des notifications'),
                    subtitle: Text('Toutes les heures'),
                    trailing: Icon(Icons.arrow_forward_ios_rounded),
                  ),
                  const ListTile(
                    leading: Icon(Icons.volume_up_rounded),
                    title: Text('Son des notifications'),
                    subtitle: Text('Son par défaut'),
                    trailing: Icon(Icons.arrow_forward_ios_rounded),
                  ),
                  const ListTile(
                    leading: Icon(Icons.vibration_rounded),
                    title: Text('Vibration'),
                    subtitle: Text('Activée'),
                    trailing: Icon(Icons.arrow_forward_ios_rounded),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Text('Notifications actives', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('${notificationTypes.where((n) => n['enabled']).length} types activés'),
                        const Text('Dernière notification : il y a 2h'),
                      ],
                    ),
                  ),
                  if (resultMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(resultMessage!, style: const TextStyle(color: Colors.green)),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    setState(() => isLoading = true);
                    // Simuler la sauvegarde des préférences
                    await Future.delayed(const Duration(milliseconds: 1000));
                    setState(() {
                      resultMessage = 'Préférences sauvegardées !';
                      isLoading = false;
                    });
                    await Future.delayed(const Duration(seconds: 1));
                    Navigator.pop(context);
                  },
                  child: isLoading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Sauvegarder'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showStatisticsDialog() async {
    final Map<String, dynamic> stats = {
      'total_posts': 47,
      'favorite_weather': 'Ensoleillé',
      'most_active_month': 'Juillet',
      'average_temperature': 18.5,
      'rainy_days': 12,
      'sunny_days': 28,
      'challenges_won': 8,
      'achievements_unlocked': 15,
    };
    final List<Map<String, dynamic>> monthlyData = [
      {'month': 'Jan', 'temp': 5, 'rain': 8, 'sun': 3},
      {'month': 'Fév', 'temp': 7, 'rain': 6, 'sun': 5},
      {'month': 'Mar', 'temp': 12, 'rain': 7, 'sun': 8},
      {'month': 'Avr', 'temp': 15, 'rain': 5, 'sun': 12},
      {'month': 'Mai', 'temp': 18, 'rain': 4, 'sun': 15},
      {'month': 'Juin', 'temp': 22, 'rain': 3, 'sun': 18},
    ];
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Statistiques météo personnelles'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Vos données météo et tendances personnelles.'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard('Publications', '${stats['total_posts']}', Icons.post_add_rounded),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard('Défis gagnés', '${stats['challenges_won']}', Icons.emoji_events_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard('Succès', '${stats['achievements_unlocked']}', Icons.star_rounded),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard('Temp. moy.', '${stats['average_temperature']}°C', Icons.thermostat_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Tendances mensuelles', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: monthlyData.length,
                        itemBuilder: (context, index) {
                          final data = monthlyData[index];
                          return Container(
                            width: 80,
                            margin: const EdgeInsets.only(right: 8),
                            child: Column(
                              children: [
                                Text(data['month'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text('${data['temp']}°C'),
                                Text('${data['rain']}j pluie'),
                                Text('${data['sun']}j soleil'),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const Text('Insights personnalisés', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('• Votre météo préférée : ${stats['favorite_weather']}'),
                          Text('• Mois le plus actif : ${stats['most_active_month']}'),
                          Text('• ${stats['sunny_days']} jours ensoleillés vs ${stats['rainy_days']} jours de pluie'),
                          const Text('• Vous êtes un passionné de météo !'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.download_rounded),
                            label: const Text('Exporter'),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Export en cours...')),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.share_rounded),
                            label: const Text('Partager'),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Partage de vos stats...')),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fermer'),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    setState(() => isLoading = true);
                    // Simuler le rafraîchissement des stats
                    await Future.delayed(const Duration(milliseconds: 1000));
                    setState(() => isLoading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Statistiques mises à jour !')),
                    );
                  },
                  child: isLoading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Actualiser'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: Colors.blue, size: 24),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Future<void> _showWidgetsDialog() async {
    final List<Map<String, dynamic>> availableWidgets = [
      {'type': 'current_weather', 'name': 'Météo actuelle', 'size': 'Petit', 'enabled': true, 'icon': Icons.wb_sunny_rounded},
      {'type': 'forecast', 'name': 'Prévisions 5 jours', 'size': 'Moyen', 'enabled': false, 'icon': Icons.calendar_today_rounded},
      {'type': 'alerts', 'name': 'Alertes météo', 'size': 'Petit', 'enabled': true, 'icon': Icons.warning_rounded},
      {'type': 'social_feed', 'name': 'Fil social', 'size': 'Grand', 'enabled': false, 'icon': Icons.forum_rounded},
      {'type': 'challenges', 'name': 'Défis actifs', 'size': 'Moyen', 'enabled': true, 'icon': Icons.flag_rounded},
      {'type': 'iot_data', 'name': 'Données IoT', 'size': 'Petit', 'enabled': false, 'icon': Icons.devices_rounded},
    ];
    bool isLoading = false;
    String? resultMessage;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Widgets d\'écran d\'accueil'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Personnalisez vos widgets pour un accès rapide à la météo.'),
                    const SizedBox(height: 16),
                    ...availableWidgets.map((widget) => Card(
                      child: ListTile(
                        leading: Icon(widget['icon'], color: Colors.blue),
                        title: Text(widget['name']),
                        subtitle: Text('Taille : ${widget['size']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: widget['enabled'],
                              onChanged: (value) {
                                setState(() {
                                  widget['enabled'] = value;
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.settings_rounded),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Configuration de ${widget['name']}')),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    )),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const Text('Aperçu des widgets', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                    child: Text('☀️ 22°C\nParis', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                    child: Text('⚠️ Alerte\nPluie', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Instructions', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('1. Activez les widgets souhaités'),
                    const Text('2. Allez dans les paramètres de votre appareil'),
                    const Text('3. Ajoutez les widgets Météo à votre écran d\'accueil'),
                    const Text('4. Les widgets se mettront à jour automatiquement'),
                    if (resultMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(resultMessage!, style: const TextStyle(color: Colors.green)),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    setState(() => isLoading = true);
                    // Simuler la configuration des widgets
                    await Future.delayed(const Duration(milliseconds: 1000));
                    setState(() {
                      resultMessage = 'Widgets configurés !';
                      isLoading = false;
                    });
                    await Future.delayed(const Duration(seconds: 1));
                    Navigator.pop(context);
                  },
                  child: isLoading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Configurer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showARModeDialog() async {
    final List<Map<String, dynamic>> arFeatures = [
      {'name': 'Météo flottante', 'description': 'Informations météo superposées', 'enabled': true},
      {'name': 'Prévisions visuelles', 'description': 'Animations météo futures', 'enabled': true},
      {'name': 'Alertes AR', 'description': 'Alertes météo en réalité augmentée', 'enabled': false},
      {'name': 'Navigation météo', 'description': 'Itinéraire optimisé selon la météo', 'enabled': false},
      {'name': 'Comparaison temps réel', 'description': 'Comparer météo actuelle vs prévue', 'enabled': true},
    ];
    bool isLoading = false;
    String? resultMessage;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Mode Réalité Augmentée'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Vivez la météo en réalité augmentée avec des informations superposées sur votre environnement.'),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const Text('Aperçu AR', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Text('☀️ 22°C - Ensoleillé'),
                          const Text('🌤️ Demain: 18°C - Nuageux'),
                          const Text('⚠️ Alerte: Pluie dans 2h'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Fonctionnalités AR', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...arFeatures.map((feature) => SwitchListTile(
                      title: Text(feature['name']),
                      subtitle: Text(feature['description']),
                      value: feature['enabled'],
                      onChanged: (value) {
                        setState(() {
                          feature['enabled'] = value;
                        });
                      },
                    )),
                    const SizedBox(height: 16),
                    const Text('Instructions AR', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('1. Pointez votre caméra vers le ciel'),
                    const Text('2. Les informations météo apparaîtront'),
                    const Text('3. Balayez pour voir les prévisions'),
                    const Text('4. Appuyez pour plus de détails'),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const Text('Conseils d\'utilisation', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Text('• Utilisez en extérieur pour de meilleurs résultats'),
                          const Text('• Évitez les zones sombres'),
                          const Text('• Gardez votre appareil stable'),
                          const Text('• Activez la localisation pour plus de précision'),
                        ],
                      ),
                    ),
                    if (resultMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(resultMessage!, style: const TextStyle(color: Colors.green)),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    setState(() => isLoading = true);
                    // Simuler l'activation du mode AR
                    await Future.delayed(const Duration(milliseconds: 1500));
                    setState(() {
                      resultMessage = 'Mode AR activé !';
                      isLoading = false;
                    });
                    await Future.delayed(const Duration(seconds: 1));
                    Navigator.pop(context);
                    // TODO: Lancer l'écran AR
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ouverture du mode AR...')),
                    );
                  },
                  child: isLoading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Activer AR'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showCalendarIntegrationDialog() async {
    final List<Map<String, dynamic>> upcomingEvents = [
      {'title': 'Réunion en extérieur', 'date': '2024-01-15 14:00', 'weather': 'Ensoleillé, 22°C', 'recommendation': 'Conditions parfaites'},
      {'title': 'Pique-nique au parc', 'date': '2024-01-16 12:00', 'weather': 'Nuageux, 18°C', 'recommendation': 'Prévoir une veste'},
      {'title': 'Course matinale', 'date': '2024-01-17 07:00', 'weather': 'Pluvieux, 12°C', 'recommendation': 'Reportez ou courez en salle'},
    ];
    final List<Map<String, dynamic>> calendarSettings = [
      {'name': 'Calendrier Google', 'connected': true, 'type': 'google'},
      {'name': 'Calendrier Apple', 'connected': false, 'type': 'apple'},
      {'name': 'Calendrier Outlook', 'connected': false, 'type': 'outlook'},
    ];
    bool isLoading = false;
    String? resultMessage;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Intégration Calendrier'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Recevez des prévisions météo personnalisées pour vos événements.'),
                    const SizedBox(height: 16),
                    const Text('Calendriers connectés', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...calendarSettings.map((calendar) => Card(
                      child: ListTile(
                        leading: Icon(
                          calendar['connected'] ? Icons.check_circle_rounded : Icons.circle_outlined,
                          color: calendar['connected'] ? Colors.green : Colors.grey,
                        ),
                        title: Text(calendar['name']),
                        subtitle: Text(calendar['connected'] ? 'Connecté' : 'Non connecté'),
                        trailing: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              calendar['connected'] = !calendar['connected'];
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${calendar['name']} ${calendar['connected'] ? 'connecté' : 'déconnecté'}')),
                            );
                          },
                          child: Text(calendar['connected'] ? 'Déconnecter' : 'Connecter'),
                        ),
                      ),
                    )),
                    const SizedBox(height: 16),
                    const Text('Événements à venir avec météo', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...upcomingEvents.map((event) => Card(
                      child: ListTile(
                        leading: Icon(_getWeatherIcon(event['weather']), color: Colors.blue),
                        title: Text(event['title']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(event['date']),
                            Text(event['weather']),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getRecommendationColor(event['recommendation']),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            event['recommendation'],
                            style: const TextStyle(fontSize: 10, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    )),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const Text('Fonctionnalités calendrier', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Text('• Prévisions météo pour chaque événement'),
                          const Text('• Suggestions d\'adaptation selon la météo'),
                          const Text('• Alertes météo pour événements en extérieur'),
                          const Text('• Planification automatique selon les conditions'),
                        ],
                      ),
                    ),
                    if (resultMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(resultMessage!, style: const TextStyle(color: Colors.green)),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    setState(() => isLoading = true);
                    // Simuler la synchronisation des calendriers
                    await Future.delayed(const Duration(milliseconds: 1500));
                    setState(() {
                      resultMessage = 'Calendriers synchronisés !';
                      isLoading = false;
                    });
                    await Future.delayed(const Duration(seconds: 1));
                    Navigator.pop(context);
                  },
                  child: isLoading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Synchroniser'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  IconData _getWeatherIcon(String weather) {
    if (weather.contains('Ensoleillé')) return Icons.wb_sunny_rounded;
    if (weather.contains('Nuageux')) return Icons.cloud_rounded;
    if (weather.contains('Pluvieux')) return Icons.umbrella_rounded;
    return Icons.wb_sunny_rounded;
  }

  Color _getRecommendationColor(String recommendation) {
    if (recommendation.contains('parfaites')) return Colors.green;
    if (recommendation.contains('Prévoir')) return Colors.orange;
    if (recommendation.contains('Reportez')) return Colors.red;
    return Colors.blue;
  }

  Future<void> _showAccessibilityDialog() async {
    final List<Map<String, dynamic>> accessibilityFeatures = [
      {'name': 'Synthèse vocale', 'description': 'Lecture à voix haute des prévisions', 'enabled': true},
      {'name': 'Contraste élevé', 'description': 'Interface haute visibilité', 'enabled': false},
      {'name': 'Gros texte', 'description': 'Police agrandie pour la lecture', 'enabled': false},
      {'name': 'Descriptions audio', 'description': 'Descriptions des conditions météo', 'enabled': true},
      {'name': 'Vibrations', 'description': 'Retour haptique pour les alertes', 'enabled': true},
      {'name': 'Gestes simplifiés', 'description': 'Navigation par gestes adaptés', 'enabled': false},
    ];
    final List<Map<String, dynamic>> voiceCommands = [
      {'command': 'Météo aujourd\'hui', 'action': 'Affiche la météo actuelle'},
      {'command': 'Prévisions demain', 'action': 'Ouvre les prévisions'},
      {'command': 'Alertes météo', 'action': 'Affiche les alertes actives'},
      {'command': 'Nouveau défi', 'action': 'Lance un défi météo'},
    ];
    bool isLoading = false;
    String? resultMessage;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Accessibilité avancée'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Personnalisez l\'application pour une meilleure accessibilité.'),
                    const SizedBox(height: 16),
                    const Text('Fonctionnalités d\'accessibilité', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...accessibilityFeatures.map((feature) => SwitchListTile(
                      title: Text(feature['name']),
                      subtitle: Text(feature['description']),
                      value: feature['enabled'],
                      onChanged: (value) {
                        setState(() {
                          feature['enabled'] = value;
                        });
                      },
                    )),
                    const SizedBox(height: 16),
                    const Text('Commandes vocales', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...voiceCommands.map((command) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.mic_rounded, color: Colors.blue),
                        title: Text(command['command']),
                        subtitle: Text(command['action']),
                        trailing: IconButton(
                          icon: const Icon(Icons.play_arrow_rounded),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Test de la commande : ${command['command']}')),
                            );
                          },
                        ),
                      ),
                    )),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const Text('Fonctionnalités spéciales', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Text('• Mode daltonien : Adaptation des couleurs'),
                          const Text('• Navigation au clavier : Contrôle complet'),
                          const Text('• Sous-titres : Transcriptions audio'),
                          const Text('• Mode sombre : Réduction de la fatigue visuelle'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Test d\'accessibilité', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.volume_up_rounded),
                            label: const Text('Test vocal'),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Test de la synthèse vocale...')),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.contrast_rounded),
                            label: const Text('Test contraste'),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Test du mode contraste élevé...')),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    if (resultMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(resultMessage!, style: const TextStyle(color: Colors.green)),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    setState(() => isLoading = true);
                    // Simuler la sauvegarde des paramètres d'accessibilité
                    await Future.delayed(const Duration(milliseconds: 1000));
                    setState(() {
                      resultMessage = 'Paramètres d\'accessibilité sauvegardés !';
                      isLoading = false;
                    });
                    await Future.delayed(const Duration(seconds: 1));
                    Navigator.pop(context);
                  },
                  child: isLoading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Sauvegarder'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fil Social Météo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.accessibility_rounded),
            tooltip: 'Accessibilité',
            onPressed: () async {
              await _showAccessibilityDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today_rounded),
            tooltip: 'Calendrier',
            onPressed: () async {
              await _showCalendarIntegrationDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.view_in_ar_rounded),
            tooltip: 'Mode AR',
            onPressed: () async {
              await _showARModeDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.widgets_rounded),
            tooltip: 'Widgets',
            onPressed: () async {
              await _showWidgetsDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: 'Statistiques',
            onPressed: () async {
              await _showStatisticsDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_rounded),
            tooltip: 'Notifications',
            onPressed: () async {
              await _showNotificationsDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.devices_rounded),
            tooltip: 'IoT Connect',
            onPressed: () async {
              await _showIoTIntegrationDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.analytics_rounded),
            tooltip: 'Prévisions avancées',
            onPressed: () async {
              await _showAdvancedForecastDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.flight_rounded),
            tooltip: 'Mode Voyage',
            onPressed: () async {
              await _showTravelModeDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_active_rounded),
            tooltip: 'Alertes personnalisées',
            onPressed: () async {
              await _showCustomAlertsDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.compare_arrows_rounded),
            tooltip: 'Comparatif météo',
            onPressed: () async {
              await _showWeatherComparisonDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.flag_rounded),
            tooltip: 'Défi météo',
            onPressed: () async {
              await _showChallengeDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_comment_rounded),
            tooltip: 'Nouvelle publication',
            onPressed: () async {
              await _showCreatePostDialog();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshFeed,
        child: Column(
          children: [
            FutureBuilder<List<WeatherChallenge>>(
              future: _challengesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: LinearProgressIndicator(),
                  );
                } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox();
                }
                final challenges = snapshot.data!;
                return SizedBox(
                  height: 140,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: challenges.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, i) {
                      final c = challenges[i];
                      return Card(
                        color: Colors.blue.shade50,
                        elevation: 3,
                        child: Container(
                          width: 220,
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.type.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(c.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                              const Spacer(),
                              Text('Participants : ${c.participants.length}', style: const TextStyle(fontSize: 12)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.play_arrow_rounded),
                                      label: const Text('Participer'),
                                      onPressed: () async {
                                        final success = await _socialService.joinWeatherChallenge(c.id);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(success ? 'Participation enregistrée !' : 'Erreur lors de la participation.')),
                                        );
                                        _refreshFeed();
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    icon: const Icon(Icons.info_outline_rounded),
                                    onPressed: () => _showChallengeDetailsDialog(c.toJson()),
                                    tooltip: 'Voir les détails',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            Expanded(
              child: FutureBuilder<List<SocialPost>>(
                future: _feedFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error loading feed'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No posts yet. Be the first to share the weather!'));
                  }
                  final posts = snapshot.data!;
                  return ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 4,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: post.userAvatar.isNotEmpty ? NetworkImage(post.userAvatar) : null,
                            child: post.userAvatar.isEmpty ? const Icon(Icons.person) : null,
                          ),
                          title: Text(post.userName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(post.formattedMessage),
                              const SizedBox(height: 4),
                              Text(post.formattedTimestamp, style: TextStyle(fontSize: 12, color: Colors.grey)),
                              if (post.imageUrl != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Image.network(post.imageUrl!, height: 120, fit: BoxFit.cover),
                                ),
                              if (post.videoUrl != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Icon(Icons.videocam_rounded, color: Colors.blueGrey),
                                ),
                              Wrap(
                                spacing: 4,
                                children: post.hashtags.map((h) => Chip(label: Text(h))).toList(),
                              ),
                              if (post.metadata['comments'] != null && (post.metadata['comments'] as List).isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    const Divider(),
                                    const Text('Commentaires', style: TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    ...(post.metadata['comments'] as List).take(3).map((comment) => Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            radius: 12,
                                            backgroundImage: comment['userAvatar'] != null ? NetworkImage(comment['userAvatar']) : null,
                                            child: comment['userAvatar'] == null ? const Icon(Icons.person, size: 16) : null,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(comment['userName'] ?? 'Utilisateur', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                                    const SizedBox(width: 8),
                                                    Text(comment['timestamp'] ?? '', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                                  ],
                                                ),
                                                Text(comment['content'] ?? '', style: const TextStyle(fontSize: 12)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                    if ((post.metadata['comments'] as List).length > 3)
                                      TextButton(
                                        onPressed: () {
                                          // TODO: Ouvrir une vue détaillée des commentaires
                                        },
                                        child: const Text('Voir plus de commentaires...'),
                                      ),
                                    if (post.metadata['reactions'] != null && (post.metadata['reactions'] as Map).isNotEmpty)
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 8),
                                          const Divider(),
                                          const Text('Réactions', style: TextStyle(fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 4),
                                          Wrap(
                                            spacing: 8,
                                            children: (post.metadata['reactions'] as Map).entries.map((entry) => Chip(
                                              label: Text('${entry.key} ${entry.value}'),
                                              backgroundColor: Colors.blue.shade50,
                                            )).toList(),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(
                                  post.likedBy.contains('me') ? Icons.favorite : Icons.favorite_border,
                                  color: post.likedBy.contains('me') ? Colors.red : null,
                                ),
                                onPressed: () async {
                                  await _socialService.togglePostLike(post.id);
                                  _refreshFeed();
                                },
                              ),
                              Text('${post.likes}'),
                              IconButton(
                                icon: const Icon(Icons.share_rounded),
                                onPressed: () async {
                                  await _showShareDialog(post);
                                },
                              ),
                              Text('${post.shares}'),
                              IconButton(
                                icon: const Icon(Icons.comment_rounded),
                                onPressed: () async {
                                  await _showCommentDialog(post);
                                },
                              ),
                              Text('${post.metadata['comments']?.length ?? 0}'),
                              IconButton(
                                icon: const Icon(Icons.emoji_emotions_rounded),
                                onPressed: () async {
                                  await _showReactionDialog(post);
                                },
                              ),
                              Text('${post.metadata['reactions']?.length ?? 0}'),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 