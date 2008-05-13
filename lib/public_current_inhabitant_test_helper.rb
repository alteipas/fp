module PublicCurrentInhabitantTestHelper
  module RedefinedMethods
    def current_inhabitant
      super
    end
    def current_inhabitant=(new)
      super(new)
    end
  end
  ApplicationController.send(:include,RedefinedMethods)

end

