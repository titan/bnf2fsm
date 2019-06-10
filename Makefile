NAME=bnf2fsm

include .config
ESCAPED_BUILDDIR = $(shell echo '${BUILDDIR}' | sed 's%/%\\/%g')
TARGET=$(NAME).py
FSM=lex_fsm.py syntax_fsm.py

vpath %.org .
vpath %.py $(BUILDDIR)
vpath %.txt $(BUILDDIR)

all: $(TARGET) $(FSM)
	chmod 755 $(BUILDDIR)/$(NAME).py

$(TARGET): %.py: %.org
	sed 's/$$$\{BUILDDIR}/$(ESCAPED_BUILDDIR)/g' $< | sed 's/$$$\{NAME}/$(NAME)/g' | org-tangle -

$(subst .py,.txt,$(FSM)): $(NAME).org
	sed 's/$$$\{BUILDDIR}/$(ESCAPED_BUILDDIR)/g' $< | sed 's/$$$\{NAME}/$(NAME)/g' | org-tangle -

$(FSM): %.py: %.txt
	naive-fsm-generator.py --lang python $(addprefix $(BUILDDIR)/, $(notdir $<)) -d $(BUILDDIR) $(FSMFLAGS)

clean:
	rm -rf $(BUILDDIR)

.PHONY: all clean
