Function Main()
	if WScript.Arguments.Count < 1 then
		WScript.Echo "Missing parameters"
	end if
	WScript.Echo WScript.Arguments(0)&"..."
	
	Set app = CreateObject("Illustrator.Application")
	Set docRef = app.Open(WScript.Arguments(0))
	app.executeMenuCommand("Clipping Masks menu item")
	app.executeMenuCommand("clear")
	WHILE(app.ActionIsRunning)
		WScript.sleep 1000
	WEND
	app.executeMenuCommand("save")
	app.executeMenuCommand("close")
	
	'WScript.Echo inputs, outputFolder
	Main = "OK"
End Function


Main