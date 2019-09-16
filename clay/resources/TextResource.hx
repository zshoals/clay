package clay.resources;


import clay.system.ResourceManager;


class TextResource extends Resource {


	public var text:String;


	public function new(text:String) {

		this.text = text;
		
		resourceType = ResourceType.text;
		
	}

	override function memoryUse() {
		
        return text != null ? text.length : 0;
        
	}


}
