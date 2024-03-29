import 'package:flutter/material.dart';
import 'package:blinkcard_flutter/microblink_scanner.dart' as blinkcard;
import 'package:blinkcard_flutter/overlay_settings.dart';
import 'package:blinkcard_flutter/overlays/blinkcard_overlays.dart';
import 'package:blinkcard_flutter/recognizer.dart' as blinkcardRecognizer;
import 'package:blinkcard_flutter/recognizers/blink_card_recognizer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _firstName = "";
  String _lastName = "";
  String _documentNumber = "";
  String _cardNumber = "";
  String _ownerName = "";

  void scanCreditCard() async {
    String license;
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      license =
      "sRwAAAEeY29tLmV0aGlvcGlhbmFpcmxpbmVzLmV0bW9iaWxlYL37NAHJujK9Vyw/8wHr+sNTGHvJ1fZJowVaUSyJmJGQlEcaTAB6RAqzdI/YgD6Ax40L1Ha4YZkrt5D0THW8RrJKfw1gMI1CkoYNZGS3BkFgZnFVYYU4wAzIQTIDdcfitj719u38yWSkPzDBQMLbbdiZuJsmFqJz/D8GanUZvVcxObnv5Tv/";
    } else if (Theme.of(context).platform == TargetPlatform.android) {
      license =
      "sRwAAAAnY29tLmV0aGlvcGlhbmFpcmxpbmVzLmV0aGlvcGlhbmFpcmxpbmVztjdiLN/+l4a6uncS6a870LCKooP4eju4kWY3E0FYeVY0apCRybQNFqfA5lOv4sRS8/5S8TcmfFwlqzrtA6HKjMFXEr/PqyN3g+D8USpwJcL0SgZlHAfrTQHgrKoy0pitLh2VaX2D5V7DcEVT20ZX0Wj7UFHn9swDe9JrF9oA+HfygcVJAOLy";
    } else {
      license = "";
    }

    var cardRecognizer = BlinkCardRecognizer()
      ..returnFullDocumentImage = true;

    BlinkCardOverlaySettings settings = BlinkCardOverlaySettings()
      ..firstSideInstructions = 'Place front side of payment card'
      ..flipCardInstructions = 'Place back side of payment card'
      ..enableBeep = true;

    try {
      var results = await blinkcard.MicroblinkScanner.scanWithCamera(
          blinkcardRecognizer.RecognizerCollection([cardRecognizer]),
          settings,
          license);

      if (results.isEmpty) return null;
      for (var result in results) {
        if (result is BlinkCardRecognizerResult) {
          setState(() {
            _cardNumber = (result.cardNumber?.contains(" ") ?? false
                ? result.cardNumber?.replaceAll(" ", "")
                : result.cardNumber) ??
                "";
            _ownerName =  result.owner ?? "";

          });

        }
      }
    } catch (ex, stack) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    Widget scannedIdentityDocument = Container();
    Widget scannedPaymentCard = Container();
    if (_firstName != null && _lastName != "") {
      scannedIdentityDocument = Column(
        children: <Widget>[
          const Text("Full name:"),
          Text("$_firstName $_lastName"),
          const Text("Document number"),
          Text(_documentNumber),
        ],
      );
    }
    if(_ownerName !=null && _cardNumber != null){
      scannedPaymentCard = Column(
        children: <Widget>[
          const Text("Full name:"),
          Text(_ownerName),
          const Text("Card number"),
          Text(_cardNumber),
        ],
      );
    }


    return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text("BlinkId Sample"),
          ),
          body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  children: <Widget>[

                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: ElevatedButton(
                        child: const Text("Scan payment card"),
                        onPressed: () => scanCreditCard(),
                      ),
                    ),
                    scannedIdentityDocument,
                    const SizedBox(height: 10,),
                    scannedPaymentCard,
                  ],
                ),
              )),
        ));
  }
}