NAME=bnf2fsm

include .config
ESCAPED_BUILDDIR = $(shell echo '${BUILDDIR}' | sed 's%/%\\/%g')
TARGET=$(NAME).py
LEXFSM=lex_fsm.py
SYNFSM=syntax_fsm.py

vpath %.org .
vpath %.py $(BUILDDIR)
vpath %.txt $(BUILDDIR)

all: $(TARGET) $(LEXFSM) $(SYNFSM)
	chmod 755 $(BUILDDIR)/$(NAME).py

$(TARGET): %.py: %.org
	sed 's/$$$\{BUILDDIR}/$(ESCAPED_BUILDDIR)/g' $< | sed 's/$$$\{NAME}/$(NAME)/g' | org-tangle -

$(subst .py,.txt,$(LEXFSM)): $(NAME).org
	sed 's/$$$\{BUILDDIR}/$(ESCAPED_BUILDDIR)/g' $< | sed 's/$$$\{NAME}/$(NAME)/g' | org-tangle -

$(subst .py,.bnf,$(SYNFSM)): $(NAME).org
	sed 's/$$$\{BUILDDIR}/$(ESCAPED_BUILDDIR)/g' $< | sed 's/$$$\{NAME}/$(NAME)/g' | org-tangle -

$(LEXFSM) $(SYNFSM): %.py: %.txt
	naive-fsm-generator.py --lang python $(addprefix $(BUILDDIR)/, $(notdir $<)) -d $(BUILDDIR) $(FSMFLAGS)

$(subst .py,.txt,$(SYNFSM)): %.txt: %.bnf
	bnf2fsm.py $(addprefix $(BUILDDIR)/, $(notdir $<)) $(addprefix $(BUILDDIR)/, $(notdir $@))

clean:
	rm -rf $(BUILDDIR)

.PHONY: all clean
