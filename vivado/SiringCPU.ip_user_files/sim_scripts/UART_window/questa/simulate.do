onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib UART_window_opt

do {wave.do}

view wave
view structure
view signals

do {UART_window.udo}

run -all

quit -force
