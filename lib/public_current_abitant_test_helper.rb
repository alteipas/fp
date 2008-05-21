module PublicCurrentAbitantTestHelper
  module RedefinedMethods
    def current_abitant
      super
    end
    def current_abitant=(new)
      super(new)
    end
  end
  ApplicationController.send(:include,RedefinedMethods)

end

