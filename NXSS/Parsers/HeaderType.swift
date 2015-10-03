
import Foundation


enum HeaderType {
	case StyleMixin
	case StyleClass
	
	/**
		:param:		string		i.e. 
								"@mixin foo($a,$b)"
								"SomeClass"
    
        :return:
            headerType          The type
            headerString        The "clean" string (i.e. without the prefix @mixin if there was any)
	*/
    static func parse( string : String ) throws -> HeaderType {
        let s = string.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
        if s.hasPrefix("@mixin") {
            return .StyleMixin
            
        } else if s.characters.count > 0 {
            return .StyleClass
        }

        var msg = "This line does not contain valid header (ie \"@mixin foo($a,$b)\"):\n"
        msg += string
        throw ParseError.Unexpected(msg:msg)
	}
}