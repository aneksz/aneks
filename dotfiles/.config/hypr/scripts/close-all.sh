#!/bin/bash

echo "Closing all active windows..."

hyprctl eval '
for _, win in ipairs(hl.get_windows()) do
    hl.dispatch(hl.dsp.window.close({ window = win }))
end
'