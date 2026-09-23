PYTHON ?= python3
IVERILOG ?= $(shell command -v iverilog 2>/dev/null)

.PHONY: test test-py test-rtl

test: test-py test-rtl

test-py:
	$(PYTHON) -m unittest discover -s tests -v

test-rtl:
ifeq ($(IVERILOG),)
	@echo "iverilog not installed - skip"
else
	$(IVERILOG) -o /tmp/tb_pwm.vvp rtl/pwm_ch.v sim/tb_pwm.v && vvp /tmp/tb_pwm.vvp
	$(IVERILOG) -o /tmp/tb_smp.vvp rtl/sync2.v rtl/pulse_sampler.v sim/tb_sampler.v && vvp /tmp/tb_smp.vvp
	$(IVERILOG) -o /tmp/tb_uart.vvp rtl/sync2.v rtl/uart_tx.v rtl/uart_rx.v sim/tb_uart.v && vvp /tmp/tb_uart.vvp
endif
