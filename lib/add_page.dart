import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
CollectionReference housingRef = firestore.collection('Housing');

class AddPage extends StatelessWidget {
  final double lat;
  final double lng;
  AddPage(this.lng, this.lat, {Key? key}) : super(key: key);
  final titleField = TextEditingController();
  final descriptionField = TextEditingController();
  final equipmentField = TextEditingController();
  final photoField = TextEditingController();
  final priceField = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau logement'),
        backgroundColor: const Color(0xff0082FF),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Ajouter un logement'),
            Text('Latitude:' + lat.toString()),
            Text('Longitude' + lng.toString()),
            TextField(
              controller: titleField,
              decoration: const InputDecoration(
                hintText: 'Titre du logement',
              ),
            ),
            TextField(
              controller: descriptionField,
              decoration: const InputDecoration(
                hintText: 'Description du logement',
              ),
            ),
            TextField(
              controller: equipmentField,
              decoration: const InputDecoration(
                hintText: 'Équipement du logement',
              ),
            ),
            TextField(
              controller: photoField,
              decoration: const InputDecoration(
                hintText: 'Photo du logement',
              ),
            ),
            TextField(
              controller: priceField,
              decoration: const InputDecoration(
                hintText: 'Prix du logement',
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: const Color(0xffFF0052),
                ),
                child: const Text('Ajouter le logement'),
                onPressed: () => addHousing(context),
              ),
            ),
          ]
        )
      )
    );
  }

  void addHousing(context) {
    try {
      housingRef.add({
        "lat": lat,
        "lng": lng,
        "title": titleField.text,
        "description": descriptionField.text,
        "equipment": equipmentField.text,
        "photoUrl": photoField.text,
        "price": priceField.text,
      }).then((value) {
        print(value.id);
        titleField.clear();
        descriptionField.clear();
        equipmentField.clear();
        photoField.clear();
        priceField.clear();
        Navigator.pop(context);
      });
    } catch (error) {
      print(error.toString());
    }
  }
}
