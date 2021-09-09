/**
 * @File Name          : OC_AN_XMLParser
 * @Description        : Parser class to get the id's from MC.
 * @Author             : IBM
 * @Group              : OmniChannel - Service
 * @Release            : R2106
 * @Created Date       : 20th May 2021
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0        2021-05-20                 IBM                   Initial Version
 **/
public class OC_AN_XMLParser{
	public class newObjectId{
		String NewObjectID;
	}

	public List<String> parseBooks(XmlStreamReader reader){
		List<String> newObj_Ids = new List<String>();
		boolean isSafeToGetNextXmlElement = true;
		while (isSafeToGetNextXmlElement){

			if (reader.getEventType() == XmlTag.START_ELEMENT){
				if ('NewObjectID' == reader.getLocalName()){
					// Pass the book to the parseBook method (below)
					newObj_Ids.add(parseBook(reader));
				}
			}
			// Always use hasNext() before calling next() to confirm
			// that we have not reached the end of the stream
			if (reader.hasNext()){
				reader.next();
			} else{
				isSafeToGetNextXmlElement = false;
				break;
			}
		}
		return newObj_Ids;
	}

	String parseBook(XmlStreamReader reader){
		String newobjId;

		boolean isSafeToGetNextXmlElement = true;
		while (isSafeToGetNextXmlElement){
			if (reader.getEventType() == XmlTag.END_ELEMENT){
				break;
			} else if (reader.getEventType() == XmlTag.CHARACTERS){
				newobjId = reader.getText();
			}
			// Always use hasNext() before calling next() to confirm
			// that we have not reached the end of the stream
			if (reader.hasNext()){
				reader.next();
			} else{
				isSafeToGetNextXmlElement = false;
				break;
			}
		}
		return newobjId;
	}


}