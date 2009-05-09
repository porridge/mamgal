
.PHONY: all
all: pl.mo

%.mo: %.po
	msgfmt -o $@ $<

.PHONY: install
install:
	for locale in pl ; do \
	 install -m 0644 -o root -g root $$locale.mo $(DEST)/usr/share/locale/$$locale/LC_MESSAGES/mamgal.mo ; \
	done

.PHONY: refresh-pot
refresh-pot:
	rm -f mamgal.pot.new mamgal.pot.old
	cd .. && (echo mamgal; grep 'pm$$' MANIFEST) | xgettext \
	  --add-comments=TRANSLATORS: \
	  --copyright-holder="Marcin Owsiany <marcin@owsiany.pl>" \
	  -L Perl -d mamgal -o po/mamgal.pot.new -f -
	mv mamgal.pot mamgal.pot.old
	msgmerge mamgal.pot.old mamgal.pot.new > mamgal.pot
