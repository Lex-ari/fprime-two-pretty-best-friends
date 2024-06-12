module obcA {

  # ----------------------------------------------------------------------
  # Symbolic constants for port numbers
  # ----------------------------------------------------------------------

    enum Ports_RateGroups {
      rateGroup1
      rateGroup2
      rateGroup3
    }

  topology obcA {

    # ----------------------------------------------------------------------
    # Instances used in the topology
    # ----------------------------------------------------------------------

    instance a_health
    instance a_blockDrv
    instance a_tlmSend
    instance a_cmdDisp
    instance a_cmdSeq
    instance a_comDriver
    instance a_comQueue
    instance a_comStub
    instance a_deframer
    instance a_eventLogger
    instance a_fatalAdapter
    instance a_fatalHandler
    instance a_fileDownlink
    instance a_fileManager
    instance a_fileUplink
    instance a_bufferManager
    instance a_framer
    instance a_posixTime
    instance a_prmDb
    instance a_rateGroup1
    instance a_rateGroup2
    instance a_rateGroup3
    instance a_rateGroupDriver
    instance a_textLogger
    instance a_systemResources

    instance a_hub
    instance a_hubComDriver
    instance a_hubComStub
    instance a_hubComQueue
    instance a_hubDeframer
    instance a_hubFramer
    instance a_cmdSplitter

    # ----------------------------------------------------------------------
    # Pattern graph specifiers
    # ----------------------------------------------------------------------

    command connections instance a_cmdDisp

    event connections instance a_eventLogger

    param connections instance a_prmDb

    telemetry connections instance a_tlmSend

    text event connections instance a_textLogger

    time connections instance a_posixTime

    health connections instance a_health

    # ----------------------------------------------------------------------
    # Direct graph specifiers
    # ----------------------------------------------------------------------

    connections Downlink {

      a_eventLogger.PktSend -> a_comQueue.comQueueIn[0]
      a_tlmSend.PktSend -> a_comQueue.comQueueIn[1]
      a_fileDownlink.bufferSendOut -> a_comQueue.buffQueueIn[0]

      a_comQueue.comQueueSend -> a_framer.comIn
      a_comQueue.buffQueueSend -> a_framer.bufferIn

      a_framer.framedAllocate -> a_bufferManager.bufferGetCallee
      a_framer.framedOut -> a_comStub.comDataIn
      a_framer.bufferDeallocate -> a_fileDownlink.bufferReturn

      a_comDriver.deallocate -> a_bufferManager.bufferSendIn
      a_comDriver.ready -> a_comStub.drvConnected

      a_comStub.comStatus -> a_framer.comStatusIn
      a_framer.comStatusOut -> a_comQueue.comStatusIn
      a_comStub.drvDataOut -> a_comDriver.$send

    }

    connections FaultProtection {
      a_eventLogger.FatalAnnounce -> a_fatalHandler.FatalReceive
    }

    connections RateGroups {
      # Block driver
      a_blockDrv.CycleOut -> a_rateGroupDriver.CycleIn

      # Rate group 1
      a_rateGroupDriver.CycleOut[Ports_RateGroups.rateGroup1] -> a_rateGroup1.CycleIn

      # Rate group 2
      a_rateGroupDriver.CycleOut[Ports_RateGroups.rateGroup2] -> a_rateGroup2.CycleIn
      a_rateGroup2.RateGroupMemberOut[0] -> a_fileDownlink.Run
      a_rateGroup2.RateGroupMemberOut[1] -> a_cmdSeq.schedIn

      # Rate group 3
      a_rateGroupDriver.CycleOut[Ports_RateGroups.rateGroup3] -> a_rateGroup3.CycleIn
      a_rateGroup3.RateGroupMemberOut[0] -> a_health.Run
      a_rateGroup3.RateGroupMemberOut[1] -> a_blockDrv.Sched
      a_rateGroup3.RateGroupMemberOut[2] -> a_bufferManager.schedIn
      a_rateGroup3.RateGroupMemberOut[3] -> a_systemResources.run
      a_rateGroup3.RateGroupMemberOut[4] -> a_tlmSend.Run
    }

    connections Sequencer {
      a_cmdSeq.comCmdOut -> a_cmdDisp.seqCmdBuff
      a_cmdDisp.seqCmdStatus -> a_cmdSeq.cmdResponseIn
    }

    connections Uplink {

      a_comDriver.allocate -> a_bufferManager.bufferGetCallee
      a_comDriver.$recv -> a_comStub.drvDataIn
      a_comStub.comDataOut -> a_deframer.framedIn

      a_deframer.framedDeallocate -> a_bufferManager.bufferSendIn
      a_deframer.comOut -> a_cmdDisp.seqCmdBuff

      a_cmdDisp.seqCmdStatus -> a_deframer.cmdResponseIn

      a_deframer.bufferAllocate -> a_bufferManager.bufferGetCallee
      a_deframer.bufferOut -> a_fileUplink.bufferSendIn
      a_deframer.bufferDeallocate -> a_bufferManager.bufferSendIn
      a_fileUplink.bufferSendOut -> a_bufferManager.bufferSendIn
    }

    connections obcA {
      # Add here connections to user-defined components
    }
    
    connections send_hub {
      # a_hub.dataOut -> a_hubComQueue.buffQueueIn
      a_hub.dataOut -> a_hubFramer.bufferIn
      a_hub.dataOutAllocate -> a_bufferManager.bufferGetCallee

      # a_hubComQueue.buffQueueSend -> a_hubFramer.bufferIn
      # a_hubComQueue.comQueueSend -> a_hubFramer.comIn

      # a_hubFramer.framedOut -> a_hubComStub.comDataIn
      a_hubFramer.framedOut -> a_hubComDriver.$send
      # a_hubFramer.comStatusOut -> a_hubComQueue.comStatusIn
      a_hubFramer.bufferDeallocate -> a_bufferManager.bufferSendIn
      a_hubFramer.framedAllocate -> a_bufferManager.bufferGetCallee

      # a_hubComStub.comStatus -> a_hubFramer.comStatusIn
      # a_hubComStub.drvDataOut -> a_hubComDriver.$send

      a_hubComDriver.deallocate -> a_bufferManager.bufferSendIn
      # a_hubComDriver.ready -> a_hubComStub.drvConnected
    }

    connections recv_hub {
      # a_hubComDriver.$recv -> a_hubComStub.drvDataIn
      a_hubComDriver.$recv -> a_hubDeframer.framedIn
      a_hubComDriver.allocate -> a_bufferManager.bufferGetCallee
      
      # a_hubComStub.comDataOut -> a_hubDeframer.framedIn

      # a_cmdDisp.seqCmdStatus -> a_hubDeframer.cmdResponseIn

      a_hubDeframer.bufferOut -> a_hub.dataIn #this works with .bufferIn
      # a_hubDeframer.comOut -> a_cmdDisp.seqCmdBuff
      a_hubDeframer.framedDeallocate -> a_bufferManager.bufferSendIn
      a_hubDeframer.bufferAllocate -> a_bufferManager.bufferGetCallee

      a_hub.dataInDeallocate -> a_bufferManager.bufferSendIn
    }

    connections hub {
      a_hub.LogSend -> a_eventLogger.LogRecv
      a_hub.TlmSend -> a_tlmSend.TlmRecv
    }
  }

}