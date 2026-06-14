.PHONY: install test demo few-shot chain bad clean uninstall

install:
	raco pkg install --auto --skip-installed prompt-pattern/

test:
	raco test prompt-pattern/tests.rkt

demo:
	racket examples/greeting.rkt

few-shot:
	racket examples/few-shot.rkt

chain:
	racket examples/chained.rkt

bad:
	racket examples/bad-pattern.rkt

uninstall:
	raco pkg remove prompt-pattern

clean:
	find . -type d -name compiled -exec rm -rf {} +
