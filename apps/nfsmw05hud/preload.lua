-- force preload all styles and rpm and extras
style = {}
for i = 0, 10, 1 do
	style[i] = {
		tach 	= ac.getFolder(ac.FolderID.ACApps) .. 	"\\lua\\nfsmw05hud\\img\\HUD" .. i .. "\\TACH.dds",
		needle 	= ac.getFolder(ac.FolderID.ACApps) .. 	"\\lua\\nfsmw05hud\\img\\HUD" .. i .. "\\TACH_NEEDLE.dds",
		rpm7k 	= ac.getFolder(ac.FolderID.ACApps) .. 	"\\lua\\nfsmw05hud\\img\\HUD" .. i .. "\\7000.dds",
		rpm8k 	= ac.getFolder(ac.FolderID.ACApps) .. 	"\\lua\\nfsmw05hud\\img\\HUD" .. i .. "\\8000.dds",
		rpm9k 	= ac.getFolder(ac.FolderID.ACApps) .. 	"\\lua\\nfsmw05hud\\img\\HUD" .. i .. "\\9000.dds",
		rpm10k 	= ac.getFolder(ac.FolderID.ACApps) .. 	"\\lua\\nfsmw05hud\\img\\HUD" .. i .. "\\10000.dds",
	}
	ui.isImageReady(style[i].tach)
	ui.isImageReady(style[i].needle)
	ui.isImageReady(style[i].rpm7k)
	ui.isImageReady(style[i].rpm8k)
	ui.isImageReady(style[i].rpm9k)
	ui.isImageReady(style[i].rpm10k)
end
redline 	= 	ac.getFolder(ac.FolderID.ACApps) .. 		"\\lua\\nfsmw05hud\\img\\misc\\REDLINE.dds"
shiftup 	= 	ac.getFolder(ac.FolderID.ACApps) .. 		"\\lua\\nfsmw05hud\\img\\misc\\SHIFT_UP_ICON.dds"
turbo 		= 	ac.getFolder(ac.FolderID.ACApps) .. 		"\\lua\\nfsmw05hud\\img\\misc\\TURBO.dds"
turboneedle = 	ac.getFolder(ac.FolderID.ACApps) .. 		"\\lua\\nfsmw05hud\\img\\misc\\TURBO_NEEDLE.dds"
ui.isImageReady(redline)
ui.isImageReady(shiftup)
ui.isImageReady(turbo)
ui.isImageReady(turboneedle)

meter = ac.getFolder(ac.FolderID.ACApps) .. 			"\\lua\\nfsmw05hud\\img\\misc\\METER.dds"
N20_ICON = ac.getFolder(ac.FolderID.ACApps) .. 			"\\lua\\nfsmw05hud\\img\\misc\\N20_ICON.dds"
PERSUIT_ICON = ac.getFolder(ac.FolderID.ACApps) .. 		"\\lua\\nfsmw05hud\\img\\misc\\PERSUIT_ICON.dds"
ui.isImageReady(meter)
ui.isImageReady(N20_ICON)
ui.isImageReady(PERSUIT_ICON)

debugtexture = ac.getFolder(ac.FolderID.ACApps) .. 		"\\lua\\nfsmw05hud\\img\\debug.png"
ui.isImageReady(debugtexture)

--#cat stuff############
cattach		= ac.getFolder(ac.FolderID.ACApps) .. 		"\\lua\\nfsmw05hud\\img\\cat\\TACHFILL.dds"
catneedle	= ac.getFolder(ac.FolderID.ACApps) .. 		"\\lua\\nfsmw05hud\\img\\cat\\NEEDLE.dds"
catRPM		= ac.getFolder(ac.FolderID.ACApps) .. 		"\\lua\\nfsmw05hud\\img\\cat\\RPMLINES.dds"
catturbo		= ac.getFolder(ac.FolderID.ACApps) ..	"\\lua\\nfsmw05hud\\img\\cat\\TURBOFILL.dds"
catturboneedle	= ac.getFolder(ac.FolderID.ACApps) ..	"\\lua\\nfsmw05hud\\img\\cat\\TURBONEEDLE.dds"
catturbolines	= ac.getFolder(ac.FolderID.ACApps) ..	"\\lua\\nfsmw05hud\\img\\cat\\TURBOLINES.dds"
ui.isImageReady(cattach)
ui.isImageReady(catneedle)
ui.isImageReady(catRPM)
ui.isImageReady(catturbo)
ui.isImageReady(catturboneedle)
ui.isImageReady(catturbolines)
--#cat stuff############

