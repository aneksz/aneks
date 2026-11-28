// components/TimerService.qml
// The countdown itself: state, actions and the "time's up" alert. No visuals;
// the bar pill (Timer.qml) and the panel (TimerPanel.qml) only read it.
//
// It stores when the timer will end rather than counting seconds down, so it
// never drifts and is still right after the PC wakes from suspend.
import QtQuick
import QtQuick as Q   // Q.Timer: plain Timer here would be this folder's Timer.qml (the bar pill)
import Quickshell

Item {
    id: root
    visible: false

    // ── Settings ────────────────────────────────────────────────
    property bool playSound: true
    // First match is played; Arch and NixOS keep the theme in different places
    property var soundFiles: [
        "/run/current-system/sw/share/sounds/freedesktop/stereo/complete.oga",
        "/usr/share/sounds/freedesktop/stereo/complete.oga"
    ]

    // ── State ───────────────────────────────────────────────────
    property bool active: false      // a timer exists (running, paused or finished)
    property bool running: false
    property bool finished: false
    property int duration: 0         // seconds, for the progress bar
    property real endsAt: 0          // ms since epoch, while running
    property int pausedRemaining: 0  // seconds, while paused
    property real now: Date.now()

    readonly property int remaining: running ? Math.max(0, Math.ceil((endsAt - now) / 1000))
                                    : finished ? 0 : pausedRemaining
    readonly property real progress: duration > 0 ? remaining / duration : 0
    readonly property bool warning: running && remaining > 0 && remaining <= 10

    // ── Actions ─────────────────────────────────────────────────
    function start(seconds) {
        if (seconds <= 0)
            return;
        now = Date.now();
        duration = seconds;
        endsAt = now + seconds * 1000;
        pausedRemaining = 0;
        finished = false;
        running = true;
        active = true;
    }

    function pause() {
        if (!running)
            return;
        pausedRemaining = remaining;
        running = false;
    }

    function resume() {
        if (running || finished || pausedRemaining <= 0)
            return;
        now = Date.now();
        endsAt = now + pausedRemaining * 1000;
        running = true;
    }

    function toggle() {
        running ? pause() : resume();
    }

    // Add or remove time; going to zero finishes the timer
    function adjust(seconds) {
        if (!active || finished)
            return;
        const left = remaining + seconds;
        if (left <= 0) {
            finish();
            return;
        }
        if (running)
            endsAt += seconds * 1000;
        else
            pausedRemaining = left;
        duration = Math.max(left, duration + seconds);
    }

    // From the finished state: another minute
    function snooze(seconds) {
        start(seconds || 60);
    }

    function cancel() {
        running = false;
        finished = false;
        active = false;
        duration = 0;
        pausedRemaining = 0;
    }

    function finish() {
        running = false;
        pausedRemaining = 0;
        finished = true;
        active = true;
        Quickshell.execDetached(["notify-send", "-a", "Timer", "-u", "critical",
            "Time's up", formatLong(duration) + " timer finished"]);
        if (playSound)
            Quickshell.execDetached(["sh", "-c",
                'for f in "$@"; do [ -f "$f" ] || continue; ' +
                'pw-play "$f" 2>/dev/null || paplay "$f" 2>/dev/null; exit; done', "sh"].concat(soundFiles));
    }

    // ── Formatting ──────────────────────────────────────────────
    function format(seconds) {
        const h = Math.floor(seconds / 3600);
        const m = Math.floor(seconds % 3600 / 60);
        const s = seconds % 60;
        return (h > 0 ? h + ":" : "") + m.toString().padStart(2, "0") + ":" + s.toString().padStart(2, "0");
    }

    function formatLong(seconds) {
        const m = Math.round(seconds / 60);
        if (seconds < 60)
            return seconds + " s";
        return m >= 60 ? Math.floor(m / 60) + " h " + (m % 60 ? m % 60 + " min" : "") : m + " min";
    }

    // Clock time the running timer ends at, e.g. "21:35"
    readonly property string endsAtText: running ? Qt.formatTime(new Date(endsAt), "hh:mm") : ""

    // ── Tick ────────────────────────────────────────────────────
    Q.Timer {
        interval: 250
        repeat: true
        running: root.running
        triggeredOnStart: true
        onTriggered: {
            root.now = Date.now();
            if (root.remaining <= 0)
                root.finish();
        }
    }
}
