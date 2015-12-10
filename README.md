NXSS (Napster X Style Sheet) is a styling framework for iOS with SASS-like declarative syntax.

Beware that even though its syntax is similar to SASS, NXSS is _not_ SASS!
Please refer to Style Guide to supported syntax and capabilities.


```css
$primaryFontName: HelveticaNeue;
$secondaryFontName: HelveticaNeue-Light;
$primaryFontColor: #333333;
$primaryBackgroundColor: #E6E6E6;

Button {
    background-color: $primaryBackgroundColor;
    border-color: #A2A2A2;
    border-width: $primaryBorderWidth;
    font-color: $primaryFontColor;
    font-color-highlighted: #999999;
    font-name: $primaryFontName;
    font-size: 18;
}

Circle {
	corner-radius: circle;
}

BlueCircleButton {
	@include Circle;
	@include Button;
	background-color: blue;
}
```



Syntax Guide
-----

#### UIView

* background-color *(GradientColor)*
* border-color *(Color)*
* border-width *(Number)*
* corner-radius *(CornerRadiusNumber)*

#### UILabel

* font-family *(FontFamilyString)*
* font-style *(FontStyleString)*     
* font-size *(Number)*


Style Value Type
-----

* **Color** - Accepted values are: 
  - rgb/a e.g. rgb(255,255,255)  or  rgba(255,255,255,1)
  - hex e.g. #A43211  
  - UIColor e.g.  red   or   blue   or  cyan   or  (any other UIColor)

* **GradientColor** - All values from **Color** plus Linear gradient support:
  - Top to Bottom linear gradient e.g.  linear-gradient( to bottom , #AB1212 , cyan )
  - Left to Right linear gradient e.g.  linear-gradient( to right , rgba(255,255,255,1) , $somePredefinedColorVariable )
NOTE: NXSS only support kinds of values mentioned in this samples.

* **FontFamily** - This is camel-cased base font name e.g. Helvetica, AmericanTypewriter, AvenirNext, Bakersville

* **FontStyle** - This is the part that comes after hypen in a font name e.g. Italic, Bold

