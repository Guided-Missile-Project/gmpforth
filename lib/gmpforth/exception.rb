#
#  exception.rb
# 
#  Copyright (c) 2010 by Daniel Kelley
# 
#  $Id:$
#
# Exceptions

class GMPForth::UnimplementedError < StandardError; end
class GMPForth::StackEmptyError < StandardError; end
class GMPForth::StackShallowError < StandardError; end
class GMPForth::StackFullError < StandardError; end
class GMPForth::MemoryBoundsError < StandardError; end
class GMPForth::MemoryAlignmentError < StandardError; end
class GMPForth::MemoryUninitializedError < StandardError; end
class GMPForth::UnknownOpcodeError < StandardError; end
class GMPForth::IllegalExtensionError < StandardError; end
