ifneq ($(ALL_OBJCFLAGS),)

%.d: %.c
	$(SHELL) -ec '$(CC) -M $(ALL_CPPFLAGS) $(ALL_CFLAGS) $< | sed '\''s/\($*\)\.o[ :]*/$$(GNUSTEP_OBJ_DIR)\/\1.o $@ : /g'\'' > $@; [ -s $@ ] || rm -f $@'

%.d: %.m
	$(SHELL) -ec '$(CC) -M $(ALL_CPPFLAGS) $(ALL_OBJCFLAGS) $< | sed '\''s/\($*\)\.o[ :]*/$$(GNUSTEP_OBJ_DIR)\/\1.o $@ : /g'\'' > $@; [ -s $@ ] || rm -f $@'

include $(patsubst %.m,%.d,$(OBJC_FILES))

endif
