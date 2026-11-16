// Removes Gecko's 0.5px tooltip hairline border (clipped at fractional scaling).
// Loaded as an agent stylesheet because userChrome.css can't reach the generated tooltip.
try {
  const Cc = Components.classes, Ci = Components.interfaces;
  const sss = Cc["@mozilla.org/content/style-sheet-service;1"]
                .getService(Ci.nsIStyleSheetService);
  const css = "tooltip { border: none !important; }";
  const uri = Cc["@mozilla.org/network/io-service;1"]
                .getService(Ci.nsIIOService)
                .newURI("data:text/css," + encodeURIComponent(css));
  if (!sss.sheetRegistered(uri, sss.AGENT_SHEET))
    sss.loadAndRegisterSheet(uri, sss.AGENT_SHEET);
} catch (e) {}