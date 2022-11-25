Create.swf source code about dna generation:
```javascript
function getDNA(O) {
    var _loc1 = GameData.Version + ":";
    _loc1 = _loc1 + (O.Name + ":");
    _loc1 = _loc1 + (O.Scale + ":");
    _loc1 = _loc1 + (O.hatFrame + ":");
    _loc1 = _loc1 + (O.headFrame + ":");
    _loc1 = _loc1 + (O.bodyFrame + ":");
    _loc1 = _loc1 + (O.armFrame + ":");
    _loc1 = _loc1 + (O.shoeFrame + ":");
    _loc1 = _loc1 + (O.eyeFrame + ":");
    _loc1 = _loc1 + (O.mouthFrame + ":");
    _loc1 = _loc1 + (O.itemFrame + ":");
    _loc1 = _loc1 + (O.accFrame + ":");
    _loc1 = _loc1 + (O.wingFrame + ":");
    _loc1 = _loc1 + O.HairColor.substr(2, 6);
    return (_loc1);
} // End of the function
```

So, the format of DNA is:
```
<version>:<name>:<scale>:<hat>:<head>:<body>:<arm>:<shoe>:<eye>:<mouth>:<item>:<accesssory>:<wing>:<haircolor>
```

e.g. (value of "version" field in the latest Create.swf is 3.39)

```
3.39:Meiling:100:1:0:1:1:1:0:0:0:0:0:EB585A
```

but in RSGMaker's Create.swf Extended, the cases are a little bit more complex,
like this example of Meiling:

```
3.4:Meiling:100:1:0:1:1:1:0:0:0:0:0:EB585A:FFF1DD:0
3.4:Meiling:100:1:0:1:1:1:0:0:0:0:0:EB585A:2AF1DD:0 // Meiling with changed skin color
3.4:Meiling:100:1:0:1:1:1:0:0:0:0:0:EB585A:2AF1DD:0
3.4:Meiling:100:1:0:0:0:0:0:0:0:0:0:EB585A:2AF1DD:0 // Meiling with only head
```

There're more fields. (value of "version" field in the latest Create.swf Extended is 3.4)

```
<version>:<name>:<scale>:<hat>:<head>:<body>:<arm>:<shoe>:<eye>:<mouth>:<item>:<accesssory>:<wing>:<haircolor>:<skincolor>:<???>
```

(The last field is unknown,
but it can't be "effect")