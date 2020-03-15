part of 'index.dart';

class WeightInput extends StatefulWidget {
  WeightInput({ Key key }) : super(key: key);

  @override
  _WeightInputState createState() => _WeightInputState();
}

class _WeightInputState  extends State<WeightInput> {
  @override
  Widget build(BuildContext context) {
    return 
        Padding(
          padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
          child: TextField(
            key: Key('WeightInput'),
            keyboardType: TextInputType.numberWithOptions(
              decimal: true,
              signed: false
            ),
            textAlign: TextAlign.center,
            textInputAction: TextInputAction.done,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
  }
}
