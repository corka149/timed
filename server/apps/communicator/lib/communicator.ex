defmodule Communicator do
  @moduledoc """
  The communicator encapsulate the communication between the clients and persistence layer.
  """

  def send_and_receive do
    {:ok, conn} = AMQP.Connection.open(amqp_connection_config())
    {:ok, chan} = AMQP.Channel.open(conn)

    AMQP.Queue.declare(chan, queue())
    AMQP.Exchange.declare(chan, exchange())
    AMQP.Queue.bind(chan, queue(), exchange())

    AMQP.Basic.publish(chan, exchange(), "", "First message =)")

    {:ok, payload, _meta} = AMQP.Basic.get(chan, queue())
    IO.puts payload
  end

  @spec exchange :: <<_::176>>
  def exchange do
    "working_hours_exchange"
  end

  @spec queue :: <<_::152>>
  def queue do
    "working_hours_queue"
  end

  @spec amqp_connection_config :: [
          {:password, bitstring()} | {:username, bitstring()} | {:virtual_host, bitstring()}
        ]
  def amqp_connection_config do
    [
      username: Application.get_env(:communicator, :amqp_username, "guest"),
      password: Application.get_env(:communicator, :amqp_password, "guest"),
      virtual_host: Application.get_env(:communicator, :amqp_virtual_host, "/")
    ]
  end
end
