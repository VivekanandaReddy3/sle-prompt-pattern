.PHONY: install test demo few-shot bad clean uninstall

install:
	cd prompt-pattern && raco pkg install --auto || raco pkg update

test:
	raco test prompt-pattern/tests.rkt

demo:
	racket examples/greeting.rkt

few-shot:
	racket examples/few-shot.rkt

bad:
	racket examples/bad-pattern.rkt

uninstall:
	raco pkg remove prompt-pattern

clean:
	find . -type d -name compiled -exec rm -rf {} +
