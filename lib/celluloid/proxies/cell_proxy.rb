module Celluloid
  # A proxy object returned from Celluloid::Actor.new/new_link which converts
  # the normal Ruby method protocol into an inter-actor message protocol
  class CellProxy < SyncProxy
    def initialize(actor_proxy, mailbox, klass, uuid)
      super(mailbox, klass, uuid)
      @actor_proxy  = actor_proxy
      @sync_proxy   = SyncProxy.new(mailbox, klass, uuid)
      @async_proxy  = AsyncProxy.new(mailbox, klass, uuid)
      @future_proxy = FutureProxy.new(mailbox, klass, uuid)
    end

    def class
      method_missing :__send__, :class
    end

    def send(meth, *args, &block)
      method_missing :send, meth, *args, &block
    end

    def _send_(meth, *args, &block)
      method_missing :__send__, meth, *args, &block
    end

    def inspect
      method_missing :inspect
    rescue DeadActorError
      "#<Celluloid::CellProxy(#{@klass}) dead>"
    end

    def name
      method_missing :name
    end

    def is_a?(klass)
      method_missing :is_a?, klass
    end

    def kind_of?(klass)
      method_missing :kind_of?, klass
    end

    def respond_to?(meth, include_private = false)
      method_missing :respond_to?, meth, include_private
    end

    def methods(include_ancestors = true)
      method_missing :methods, include_ancestors
    end

    def method(name)
      Method.new(self, name)
    end

    def alive?
      @actor_proxy.alive?
    end

    def to_s
      method_missing :to_s
    end

    alias_method :sync, :method_missing

    # Obtain an async proxy or explicitly invoke a named async method
    def async(method_name = nil, *args, &block)
      if method_name
        @async_proxy.method_missing method_name, *args, &block
      else
        @async_proxy
      end
    end

    # Obtain a future proxy or explicitly invoke a named future method
    def future(method_name = nil, *args, &block)
      if method_name
        @future_proxy.method_missing method_name, *args, &block
      else
        @future_proxy
      end
    end

    # Terminate the associated actor
    def terminate
      @actor_proxy.terminate
    end

    # Terminate the associated actor asynchronously
    def terminate!
      @actor_proxy.terminate!
    end
  end
end
