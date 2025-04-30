import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_hub/models/designer_detailes_model.dart';

class DesignerService {
  Future<void> saveDesignerDetails(DesignerDetailesModel model) async {
    await FirebaseFirestore.instance
        .collection('designer_details')
        .doc(model.uid)
        .set(model.toMap());
  }

  Future<DesignerDetailesModel?> getDesignerDetails(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('designer_details')
        .doc(uid)
        .get();

    if (doc.exists && doc.data() != null) {
      return DesignerDetailesModel.fromMap(doc.data()!);
    } else {
      return null;
    }
  }
}
