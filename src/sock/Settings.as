package sock {

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;
	
	import events.LogEvent;
	
	/**
	 * <p>The Settings class takes care of all the saving/loading/parsing of data, Sock has the ability to save variables/values to an XML file.
	 * Make sure you set the properties of this class BEFORE running _mySock.initialize();</p>
	 * */
	public class Settings extends Sprite {

		/* SINGLETONS ========== ========== ========== ========== ========== ========== ========== ========== ========== */
		
		/** @private */
		public var utils:Utils=Utils.getInstance();								// add utils
		
		/* OPTIONAL SETTINGS === ========== ========== ========== ========== ========== ========== ========== ========== */
		
		/** clear the settings XML each time the application starts (allows you to start clean) */
		public var clearSettingsOnStartup : Boolean = false;					// clear settings on startup
		/** the name of your XML settings file */
		public var fileName : String = 'Settings';								// name of settings file
		/** save the settings file to the desktop, otherwise it'll be saved in the application storage folder (default = false) */
		public var saveToDesktop : Boolean = false;								// save to desktop, otherwise applicationStorage
		
		/* OTHER PUBLIC VARS === ========== ========== ========== ========== ========== ========== ========== ========== */
		
		/** @private */
		public var settingsObject : Object	= new Object();						// object holding all settings
		
		/* PRIVATE VARS ======== ========== ========== ========== ========== ========== ========== ========== ========== */
		
		private var _appName:String;											// application name
		private var _file:File;													// the settings file
		private var _fileLoader:DataLoader = new DataLoader();					// file loader object
		private var _XMLdata:XML;												// the XML data (to be saved)
		private var _setupComplete:Boolean = false;								// file setting load sequence complete?
		
		/* EVENTS ==== ========= ========== ========== ========== ========== ========== ========== ========== ========== */
		
		/** @private */
		public const LOADED:String = "loaded";
		private var _loadedEvent:Event = new Event(LOADED, false, false);
		
		/* FUNCTIONS ==== ========= ========== ========== ========== ========== ========== ========== ========== ========== */
		
		private function loadXML():void {
			// load the settings file
			addToLog('loading '+fileName+'.xml', "standard", "load");
			_fileLoader.loadXML(_file.url, parseXML);
		}
		
		// generate the XML (recursive function)
		private function generateXML():void{ 
			
			if (_setupComplete == false) {
				addToLog('generating base settings file', "standard", "save");
			}
			
			// create app name container
			_XMLdata = new XML(<application/>);
			_XMLdata.setName(_appName);
			_XMLdata.appendChild(populateXMLData(settingsObject));
						
			// write the data file
			writeXML();
		}
		
		// create XML data based on objects (recursive function)
		private function populateXMLData(_obj:Object, _recursive:Boolean = false):XML {
		
			var count:int = 0;
			
			var _xmlSettings:XML = new XML(<settings/>);
			
			// get the keys
			var keys:Array = new Array();
			for (var _key:String in _obj) {
				keys.push(_key);
			}
						
			// generate
			for each (var settingsObj:Object in _obj) {
								
				var _subSetting:XML;
				
				if (getQualifiedClassName(settingsObj) != 'Object' && settingsObj != null) {
					
					_subSetting = new XML(utils.toXMLProperty(keys[count], settingsObj));
					
				} else if (getQualifiedClassName(settingsObj) != 'Object' && settingsObj == null) {
					
					_subSetting = new XML(utils.toXMLProperty(keys[count]));
				
				} else {
					
					_subSetting = new XML(utils.toXMLProperty(keys[count]));
					_subSetting.appendChild(populateXMLData(settingsObj ,true).children());
				
				}
				
				_xmlSettings.appendChild(_subSetting);
				
				count++;
			}
			
			return _xmlSettings;
		}
		
		// parse the XML data
		private function parseXML(_xml:XML):void{
			
			addToLog('parsing xml data', "standard", "load");
			
			settingsObject = new Object();
			settingsObject = generateSettingsObject(_xml);

			addToLog('loading settings completed succesfully', "important", "load");
			addToLog("===== ===== ===== ===== ===== ===== ", "grey");
			
			if (_setupComplete == false) {
							
				_setupComplete = true;
				dispatchEvent(_loadedEvent);
			}
		}
		
		// generate objects (recursive function)
		private function generateSettingsObject(_xml:XML, _recursive:Boolean = false):Object{
			
			var _xmlList:XMLList = new XMLList();
			var _settings:Object = new Object();
			
			// one child deeper (remove appname tag)
			if (_recursive == false) {
				_xmlList = _xml.children();
			} else {
				_xmlList = new XMLList(_xml);
			}
			
			for each (var settingXML:XML in _xmlList.children()) {
							
				if (settingXML.hasComplexContent() == false) {
					
					_settings[settingXML.name()] = String(settingXML);
					
				} else {
					
					// run function again for nested object
					_settings[settingXML.name()] = generateSettingsObject(settingXML, true);
				}
			}
			
			return _settings;
		}
		
		// write the XML to disk
		private function writeXML():void {
			
			var ba:ByteArray = new ByteArray();
			ba.writeUTFBytes(_XMLdata);
			var fs : FileStream = new FileStream;
			fs.open(_file, FileMode.WRITE);
			fs.writeBytes(ba);
			fs.close();
			
			if (_setupComplete == false) {
				addToLog(fileName+".xml created", "important", "save");
				addToLog("===== ===== ===== ===== ===== ===== ", "grey");
				_setupComplete = true;	
				dispatchEvent(_loadedEvent);
			} else {
				addToLog("settings saved", "important", "save");
			}
		}
		
		/* PUBLIC METHODS ========= ========== ========== ========== ========== ========== ========== ========== ========== */
		
		// initialize the settings class
		/** @private */
		public function initialize(applicationName:String):void {
			
			// get the app name
			_appName = applicationName;
			
			// where should the file be (created)
			if (saveToDesktop == true) {
				_file = File.desktopDirectory.resolvePath(fileName+'.xml');
			} else {
				_file = File.applicationStorageDirectory.resolvePath(fileName+'.xml');
			}
			
			// if it doesnt exist, create it
			if (!_file.exists) {
				
				addToLog(fileName+".xml couldn't be found", "warning", "load");
				generateXML();
				
			} else if (clearSettingsOnStartup == true) {
				
				addToLog("clearing settings on startup", "important", "save");
				generateXML();
				
			} else {
				
				// load the settings file
				loadXML();
			}
			
			
		}
		
		// add a setting
		/** @private */
		public function addSetting(_case:String, _value:*, _instaSave:Boolean = false):void {
		
			// never save the internal commands
			if (_case == "SOCKSERVER" || _case == "SOCKCLIENT") {
								
				return;
			}
						
			settingsObject[_case] = _value;
			
			// save setting to XML
			if (_instaSave == true) {
				generateXML();
			}
			
		}
		
		// clear all values (set to null)
		/** @private */
		public function clearAllSettings(_instaDel:Boolean = true):void {

			var count:int = 0;
			
			// get the keys
			var keys:Array = new Array();
			for (var _key:String in settingsObject) {
				keys.push(_key);
			}
			
			for each(var obj:Object in settingsObject) {
				settingsObject[keys[count]] = null;
				count++;
			}
						
			// save setting to XML
			if (_instaDel == true) {
				generateXML();
			}
			
		}
		
		// clear a value of a setting (set to null)
		/** @private */
		public function clearSetting(_case:String, _instaDel:Boolean):void {
			
			settingsObject[_case] = null;
			
			// save setting to XML
			if (_instaDel == true) {
				generateXML();
			}
			
		}
		
		// delete all settings completely (keeps empty XML file)
		/** @private */
		public function deleteAllSettings(_instaDel:Boolean):void {
			
			settingsObject = new Object();
			
			// save setting to XML
			if (_instaDel == true) {
				generateXML();
			}
			
		}
		
		// delete a setting completely
		/** @private */
		public function deleteSetting(_case:String, _instaDel:Boolean):void {
			
			settingsObject[_case] = null;
			delete(settingsObject[_case]);
			
			// save setting to XML
			if (_instaDel == true) {
				generateXML();
			}
		}
		
		// save the XML file to disk
		/** @private */
		public function updateSettings():void {
			
			generateXML();
			
		}
		
		// dispatch a log event so the widget will update its log
		private function addToLog(message:String = 'debug', format:String = 'standard', type:String = 'normal'):void {
						
			var _logEvent:LogEvent = new LogEvent('onLog', message, format, type);
			dispatchEvent(_logEvent);
		}
	
		/* SINGLETON ========== ========== ========== ========== ========== ========== ========== ========== ========== */
		
		// singleton vars
		private static var instance:Settings;
		private static var allowInstantiation:Boolean;
		
		// get instance function (singleton)
		/** @private */
		public static function getInstance():Settings {
			
			if (instance==null) {
				allowInstantiation=true;
				instance = new Settings();
				allowInstantiation=false;
			}
			return instance;	
		}
		
		// warning to use as singleton
		/** @private */
		public function Settings():void {
			
			if (! allowInstantiation) {
				throw new Error("Error: Use Settings.getInstance() instead of new.");
			}
		}
	}
}