defmodule Communicator do
  @moduledoc """
  The communicator encapsulate the communication between the clients and persistence layer.
  """

  def send_and_receive do
    {:ok, conn} = AMQP.Connection.open(username: "admin", password: "s3cr3t", virtual_host: "timed_vhost")
    {:ok, chan} = AMQP.Channel.open(conn)

    AMQP.Queue.declare(chan, queue())
    AMQP.Exchange.declare(chan, exchange())
    AMQP.Queue.bind(chan, queue(), exchange())

    AMQP.Basic.publish(chan, exchange(), "", "First message =)")

    {:ok, payload, _meta} = AMQP.Basic.get(chan, queue())
    IO.puts payload
  end

  def exchange do
    "working_hours_exchange"
  end

  def queue do
    "working_hours_queue"
  end
end
