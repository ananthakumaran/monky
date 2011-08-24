update-doc:
	makeinfo monky.texi
	rm -rf /tmp/monky-gh-pages
	git clone -b gh-pages . /tmp/monky-gh-pages
	makeinfo --html --no-split --css-ref=http://ananthakumaran.github.com/monky/monky.css -o /tmp/monky-gh-pages/index.html monky.texi
	cd /tmp/monky-gh-pages && git add index.html && git commit -m "doc update" && git push origin gh-pages
