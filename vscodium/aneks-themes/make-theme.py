#!/usr/bin/env python3
"""Generate a VSCodium colour theme from a theme's colors.toml.

Usage: make-theme.py <path/to/colors.toml> [output.json]
The theme is named after vscode_theme in colors.toml. Then add it to
package.json's "themes" list with the same label.
"""
import json
import sys
import tomllib


def mix(a, b, t):
    """Blend hex colour a toward b by t (0..1)."""
    a, b = a.lstrip("#"), b.lstrip("#")
    out = [round(int(a[i:i + 2], 16) * (1 - t) + int(b[i:i + 2], 16) * t) for i in (0, 2, 4)]
    return "#" + "".join(f"{v:02x}" for v in out)


def alpha(c, a):
    """Hex colour with an alpha byte, e.g. alpha('#112233', 0x40)."""
    return f"{c}{a:02x}"


def build(p):
    bg, fg = p["background"], p["foreground"]
    bg0, bg1, bg2, bg3 = p["bg0"], p["bg1"], p["bg2"], p["bg3"]
    fg0, fg1 = p["fg0"], p["fg1"]
    acc, acc2 = p["accent"], p["accent_alt"]
    err, warn, info, ok = p["error"], p["warn"], p["info"], p["success"]
    muted = p["color8"]
    border = p.get("border", muted)
    c = [p[f"color{i}"] for i in range(16)]
    light = p.get("color_scheme") == "prefer-light"
    on_accent = bg if not light else fg0

    colors = {
        # base
        "foreground": fg, "descriptionForeground": muted, "disabledForeground": muted,
        "errorForeground": err, "focusBorder": alpha(acc, 0x99), "icon.foreground": fg1,
        "selection.background": alpha(acc, 0x55), "widget.shadow": "#00000066",
        "textLink.foreground": acc, "textLink.activeForeground": acc2,
        "textPreformat.foreground": acc2, "textCodeBlock.background": bg1,
        "textBlockQuote.background": bg1, "textBlockQuote.border": acc,
        "sash.hoverBorder": acc,
        # editor
        "editor.background": bg, "editor.foreground": fg,
        "editorCursor.foreground": p.get("cursor", fg0),
        "editorLineNumber.foreground": muted, "editorLineNumber.activeForeground": acc,
        "editor.lineHighlightBackground": bg1, "editor.lineHighlightBorder": "#00000000",
        "editor.selectionBackground": alpha(acc, 0x40), "editor.inactiveSelectionBackground": alpha(acc, 0x20),
        "editor.selectionHighlightBackground": alpha(acc2, 0x25),
        "editor.wordHighlightBackground": alpha(acc2, 0x25), "editor.wordHighlightStrongBackground": alpha(acc, 0x30),
        "editor.findMatchBackground": alpha(warn, 0x55), "editor.findMatchHighlightBackground": alpha(warn, 0x28),
        "editor.hoverHighlightBackground": alpha(acc, 0x20), "editor.rangeHighlightBackground": alpha(acc, 0x15),
        "editorWhitespace.foreground": alpha(muted, 0x60),
        "editorIndentGuide.background1": alpha(muted, 0x40), "editorIndentGuide.activeBackground1": muted,
        "editorRuler.foreground": alpha(muted, 0x40),
        "editorBracketMatch.background": alpha(acc, 0x25), "editorBracketMatch.border": acc,
        "editorBracketHighlight.foreground1": c[4], "editorBracketHighlight.foreground2": c[5],
        "editorBracketHighlight.foreground3": c[6], "editorBracketHighlight.foreground4": c[3],
        "editorBracketHighlight.foreground5": c[2], "editorBracketHighlight.foreground6": c[1],
        "editorGutter.background": bg, "editorGutter.addedBackground": ok,
        "editorGutter.modifiedBackground": info, "editorGutter.deletedBackground": err,
        "editorError.foreground": err, "editorWarning.foreground": warn, "editorInfo.foreground": info,
        "editorHint.foreground": acc2,
        "editorInlayHint.background": alpha(bg2, 0xcc), "editorInlayHint.foreground": muted,
        "editorCodeLens.foreground": muted,
        "editorOverviewRuler.border": "#00000000",
        "editorOverviewRuler.addedForeground": ok, "editorOverviewRuler.modifiedForeground": info,
        "editorOverviewRuler.deletedForeground": err, "editorOverviewRuler.errorForeground": err,
        "editorOverviewRuler.warningForeground": warn, "editorOverviewRuler.findMatchForeground": warn,
        "editorWidget.background": bg1, "editorWidget.foreground": fg, "editorWidget.border": border,
        "editorSuggestWidget.background": bg1, "editorSuggestWidget.border": border,
        "editorSuggestWidget.foreground": fg, "editorSuggestWidget.highlightForeground": acc,
        "editorSuggestWidget.selectedBackground": bg3,
        "editorHoverWidget.background": bg1, "editorHoverWidget.border": border,
        "editorStickyScroll.background": bg,
        "peekView.border": acc, "peekViewEditor.background": bg1, "peekViewResult.background": bg1,
        "peekViewTitle.background": bg2, "peekViewEditor.matchHighlightBackground": alpha(warn, 0x40),
        "peekViewResult.matchHighlightBackground": alpha(warn, 0x40), "peekViewResult.selectionBackground": bg3,
        "diffEditor.insertedTextBackground": alpha(ok, 0x25), "diffEditor.removedTextBackground": alpha(err, 0x25),
        "diffEditor.insertedLineBackground": alpha(ok, 0x15), "diffEditor.removedLineBackground": alpha(err, 0x15),
        "merge.currentHeaderBackground": alpha(ok, 0x50), "merge.currentContentBackground": alpha(ok, 0x20),
        "merge.incomingHeaderBackground": alpha(info, 0x50), "merge.incomingContentBackground": alpha(info, 0x20),
        # chrome
        "titleBar.activeBackground": bg0, "titleBar.activeForeground": fg1,
        "titleBar.inactiveBackground": bg0, "titleBar.inactiveForeground": muted, "titleBar.border": bg0,
        "activityBar.background": bg0, "activityBar.foreground": acc, "activityBar.inactiveForeground": muted,
        "activityBar.border": bg0, "activityBar.activeBorder": acc,
        "activityBarBadge.background": acc, "activityBarBadge.foreground": on_accent,
        "sideBar.background": bg0, "sideBar.foreground": fg1, "sideBar.border": bg1,
        "sideBarTitle.foreground": fg0, "sideBarSectionHeader.background": bg0,
        "sideBarSectionHeader.foreground": fg1, "sideBarSectionHeader.border": bg1,
        "editorGroup.border": bg2, "editorGroupHeader.tabsBackground": bg0,
        "editorGroupHeader.noTabsBackground": bg0, "editorGroupHeader.tabsBorder": bg0,
        "tab.activeBackground": bg, "tab.activeForeground": fg0, "tab.activeBorderTop": acc,
        "tab.activeBorder": bg, "tab.inactiveBackground": bg0, "tab.inactiveForeground": muted,
        "tab.border": bg0, "tab.hoverBackground": bg1, "tab.unfocusedActiveForeground": fg1,
        "tab.unfocusedActiveBorderTop": alpha(acc, 0x80), "tab.activeModifiedBorder": warn,
        "breadcrumb.background": bg, "breadcrumb.foreground": muted,
        "breadcrumb.focusForeground": fg0, "breadcrumb.activeSelectionForeground": acc,
        "statusBar.background": bg0, "statusBar.foreground": fg1, "statusBar.border": bg0,
        "statusBar.noFolderBackground": bg0, "statusBar.debuggingBackground": warn,
        "statusBar.debuggingForeground": bg, "statusBarItem.hoverBackground": bg2,
        "statusBarItem.remoteBackground": acc, "statusBarItem.remoteForeground": on_accent,
        "panel.background": bg0, "panel.border": bg2, "panelTitle.activeBorder": acc,
        "panelTitle.activeForeground": fg0, "panelTitle.inactiveForeground": muted,
        "minimap.background": bg, "minimapSlider.background": alpha(muted, 0x30),
        "minimapSlider.hoverBackground": alpha(muted, 0x50), "minimapSlider.activeBackground": alpha(muted, 0x70),
        "scrollbarSlider.background": alpha(muted, 0x40), "scrollbarSlider.hoverBackground": alpha(muted, 0x70),
        "scrollbarSlider.activeBackground": alpha(acc, 0x80), "scrollbar.shadow": "#00000000",
        # inputs & buttons
        "button.background": acc, "button.foreground": on_accent, "button.hoverBackground": mix(acc, fg0, 0.15),
        "button.secondaryBackground": bg3, "button.secondaryForeground": fg,
        "button.secondaryHoverBackground": mix(bg3, fg, 0.1),
        "input.background": bg1, "input.foreground": fg, "input.border": bg3,
        "input.placeholderForeground": muted, "inputOption.activeBorder": acc,
        "inputOption.activeBackground": alpha(acc, 0x30),
        "inputValidation.errorBorder": err, "inputValidation.errorBackground": bg1,
        "inputValidation.warningBorder": warn, "inputValidation.warningBackground": bg1,
        "inputValidation.infoBorder": info, "inputValidation.infoBackground": bg1,
        "dropdown.background": bg1, "dropdown.foreground": fg, "dropdown.border": bg3,
        "checkbox.background": bg1, "checkbox.border": bg3, "checkbox.foreground": fg,
        "badge.background": acc, "badge.foreground": on_accent, "progressBar.background": acc,
        # lists, menus, pickers
        "list.activeSelectionBackground": bg3, "list.activeSelectionForeground": fg0,
        "list.inactiveSelectionBackground": bg2, "list.inactiveSelectionForeground": fg,
        "list.hoverBackground": bg1, "list.hoverForeground": fg0,
        "list.focusBackground": bg3, "list.focusOutline": alpha(acc, 0x80),
        "list.highlightForeground": acc, "list.errorForeground": err, "list.warningForeground": warn,
        "tree.indentGuidesStroke": alpha(muted, 0x60),
        "menu.background": bg1, "menu.foreground": fg, "menu.selectionBackground": bg3,
        "menu.selectionForeground": fg0, "menu.separatorBackground": bg3, "menu.border": bg2,
        "menubar.selectionBackground": bg2,
        "quickInput.background": bg1, "quickInput.foreground": fg,
        "quickInputList.focusBackground": bg3, "quickInputList.focusForeground": fg0,
        "pickerGroup.foreground": acc, "pickerGroup.border": bg3,
        "keybindingLabel.background": bg2, "keybindingLabel.foreground": fg0,
        "keybindingLabel.border": bg3, "keybindingLabel.bottomBorder": bg3,
        "notifications.background": bg1, "notifications.foreground": fg, "notifications.border": bg2,
        "notificationCenterHeader.background": bg2, "notificationToast.border": bg2,
        "notificationsErrorIcon.foreground": err, "notificationsWarningIcon.foreground": warn,
        "notificationsInfoIcon.foreground": info,
        "extensionButton.prominentBackground": acc, "extensionButton.prominentForeground": on_accent,
        "extensionButton.prominentHoverBackground": mix(acc, fg0, 0.15),
        "settings.headerForeground": fg0, "settings.modifiedItemIndicator": acc,
        "welcomePage.background": bg,
        # git
        "gitDecoration.addedResourceForeground": ok, "gitDecoration.untrackedResourceForeground": ok,
        "gitDecoration.modifiedResourceForeground": warn, "gitDecoration.deletedResourceForeground": err,
        "gitDecoration.renamedResourceForeground": info, "gitDecoration.ignoredResourceForeground": muted,
        "gitDecoration.conflictingResourceForeground": c[5],
        # terminal
        "terminal.background": bg, "terminal.foreground": fg,
        "terminalCursor.foreground": p.get("cursor", fg0), "terminal.selectionBackground": alpha(acc, 0x40),
        "terminal.ansiBlack": c[0], "terminal.ansiRed": c[1], "terminal.ansiGreen": c[2],
        "terminal.ansiYellow": c[3], "terminal.ansiBlue": c[4], "terminal.ansiMagenta": c[5],
        "terminal.ansiCyan": c[6], "terminal.ansiWhite": c[7],
        "terminal.ansiBrightBlack": c[8], "terminal.ansiBrightRed": c[9], "terminal.ansiBrightGreen": c[10],
        "terminal.ansiBrightYellow": c[11], "terminal.ansiBrightBlue": c[12],
        "terminal.ansiBrightMagenta": c[13], "terminal.ansiBrightCyan": c[14], "terminal.ansiBrightWhite": c[15],
    }

    def tok(scope, color, style=None):
        s = {"foreground": color}
        if style:
            s["fontStyle"] = style
        return {"scope": scope, "settings": s}

    tokens = [
        tok(["comment", "punctuation.definition.comment"], muted, "italic"),
        tok(["string", "string.quoted", "string.template", "markup.inline.raw"], c[2]),
        tok(["constant.character.escape", "string.regexp"], c[6]),
        tok(["constant.numeric", "constant.language", "constant.language.boolean"], c[3]),
        tok(["keyword", "storage.type", "storage.modifier", "keyword.control"], c[5]),
        tok(["keyword.operator", "punctuation.accessor"], c[6]),
        tok(["entity.name.function", "support.function", "meta.function-call"], c[4]),
        tok(["entity.name.type", "entity.name.class", "support.class", "support.type",
             "entity.other.inherited-class"], c[3]),
        tok(["variable", "variable.other.readwrite"], fg),
        tok(["variable.parameter"], fg1, "italic"),
        tok(["variable.other.property", "variable.other.object.property", "meta.object-literal.key",
             "support.type.property-name"], c[6]),
        tok(["variable.language", "variable.language.this", "variable.language.self"], c[1], "italic"),
        tok(["entity.name.tag"], c[1]),
        tok(["entity.other.attribute-name"], c[3], "italic"),
        tok(["entity.name.namespace", "entity.name.type.module"], acc2),
        tok(["meta.decorator", "entity.name.function.decorator"], c[6]),
        tok(["punctuation", "meta.brace"], mix(fg, bg, 0.35)),
        tok(["markup.heading", "entity.name.section.markdown"], acc, "bold"),
        tok(["markup.bold"], fg0, "bold"),
        tok(["markup.italic"], fg0, "italic"),
        tok(["markup.underline.link", "string.other.link"], acc),
        tok(["markup.inserted"], ok), tok(["markup.deleted"], err), tok(["markup.changed"], warn),
        tok(["invalid", "invalid.illegal"], err),
    ]

    return {
        "name": p["vscode_theme"],
        "type": "light" if light else "dark",
        "semanticHighlighting": True,
        "colors": colors,
        "tokenColors": tokens,
    }


if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    with open(sys.argv[1], "rb") as f:
        palette = tomllib.load(f)
    theme = build(palette)
    out = json.dumps(theme, indent=2) + "\n"
    if len(sys.argv) > 2:
        open(sys.argv[2], "w").write(out)
    else:
        sys.stdout.write(out)
