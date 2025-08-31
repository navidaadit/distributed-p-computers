library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.BRAM_write_shift_regs_pkg.all;

entity BRAM_write_shift_regs_wrapper is
    generic(
        AXI_ADDR_WIDTH : integer := 32;  -- width of the AXI address bus
        BASEADDR : std_logic_vector(31 downto 0) := x"00000000" -- the register file's system base address		
    );
    port(
        -- Clock and Reset
        axi_aclk    : in  std_logic;
        axi_aresetn : in  std_logic;
        -- AXI Write Address Channel
        s_axi_awaddr  : in  std_logic_vector(AXI_ADDR_WIDTH - 1 downto 0);
        s_axi_awprot  : in  std_logic_vector(2 downto 0); -- sigasi @suppress "Unused port"
        s_axi_awvalid : in  std_logic;
        s_axi_awready : out std_logic;
        -- AXI Write Data Channel
        s_axi_wdata   : in  std_logic_vector(31 downto 0);
        s_axi_wstrb   : in  std_logic_vector(3 downto 0);
        s_axi_wvalid  : in  std_logic;
        s_axi_wready  : out std_logic;
        -- AXI Read Address Channel
        s_axi_araddr  : in  std_logic_vector(AXI_ADDR_WIDTH - 1 downto 0);
        s_axi_arprot  : in  std_logic_vector(2 downto 0); -- sigasi @suppress "Unused port"
        s_axi_arvalid : in  std_logic;
        s_axi_arready : out std_logic;
        -- AXI Read Data Channel
        s_axi_rdata   : out std_logic_vector(31 downto 0);
        s_axi_rresp   : out std_logic_vector(1 downto 0);
        s_axi_rvalid  : out std_logic;
        s_axi_rready  : in  std_logic;
        -- AXI Write Response Channel
        s_axi_bresp   : out std_logic_vector(1 downto 0);
        s_axi_bvalid  : out std_logic;
        s_axi_bready  : in  std_logic;
        -- User Ports
        reset_tictoc_strobe : out std_logic; -- strobe signal for register 'reset_tictoc' (pulsed when the register is written from the bus)
        reset_tictoc_value : out std_logic_vector(0 downto 0); -- write value of field 'reset_tictoc.value'
        tictoc_counter_limit_strobe : out std_logic; -- strobe signal for register 'tictoc_counter_limit' (pulsed when the register is written from the bus)
        tictoc_counter_limit_value : out std_logic_vector(31 downto 0); -- write value of field 'tictoc_counter_limit.value'
	    flip_counter_strobe : out std_logic_vector(0 to FLIP_COUNTER_ARRAY_LENGTH-1); -- Strobe signal for register 'flip_counter' (pulsed when the register is written from the bus)
        flip_counter_value_slv : in std_logic_vector(FLIP_COUNTER_VALUE_BIT_WIDTH * FLIP_COUNTER_ARRAY_LENGTH - 1 downto 0); -- Value of register 'flip_counter', field 'value'
        reset_ref_counter_strobe : out std_logic; -- strobe signal for register 'reset_ref_counter' (pulsed when the register is written from the bus)
        reset_ref_counter_value : out std_logic_vector(0 downto 0); -- write value of field 'reset_ref_counter.value'
        s_memory_addr : out std_logic_vector(19 downto 0); -- read/write address for memory 's_memory'
        s_memory_rdata : in std_logic_vector(31 downto 0); -- read data for memory 's_memory'
        s_memory_ren : out std_logic; -- read-enable for memory 's_memory'
        s_memory_2_addr : out std_logic_vector(19 downto 0); -- read/write address for memory 's_memory_2'
        s_memory_2_rdata : in std_logic_vector(31 downto 0); -- read data for memory 's_memory_2'
        s_memory_2_ren : out std_logic; -- read-enable for memory 's_memory_2'
        j_memory_addr : out std_logic_vector(16 downto 0); -- read/write address for memory 'J_memory'
        j_memory_wdata : out std_logic_vector(31 downto 0); -- write data for memory 'J_memory'
        j_memory_wen : out std_logic_vector(3 downto 0); -- byte-wide write-enable for memory 'J_memory'
        h_memory_addr : out std_logic_vector(14 downto 0); -- read/write address for memory 'h_memory'
        h_memory_wdata : out std_logic_vector(31 downto 0); -- write data for memory 'h_memory'
        h_memory_wen : out std_logic_vector(3 downto 0); -- byte-wide write-enable for memory 'h_memory'
        j_read_trigger_strobe : out std_logic; -- strobe signal for register 'J_read_trigger' (pulsed when the register is written from the bus)
        j_read_trigger_value : out std_logic_vector(0 downto 0); -- write value of field 'J_read_trigger.value'
        h_read_trigger_strobe : out std_logic; -- strobe signal for register 'h_read_trigger' (pulsed when the register is written from the bus)
        h_read_trigger_value : out std_logic_vector(0 downto 0); -- write value of field 'h_read_trigger.value'
        frozen_strobe : out std_logic; -- strobe signal for register 'frozen' (pulsed when the register is read from the bus)
        frozen_value : in std_logic_vector(0 downto 0); -- read value of field 'frozen.value'
        weight_load_done_strobe : out std_logic; -- strobe signal for register 'weight_load_DONE' (pulsed when the register is read from the bus)
        weight_load_done_value : in std_logic_vector(0 downto 0); -- read value of field 'weight_load_DONE.value'
        active_state_counter_strobe : out std_logic; -- strobe signal for register 'active_state_counter' (pulsed when the register is written from the bus)
        active_state_counter_value : out std_logic_vector(31 downto 0); -- write value of field 'active_state_counter.value'
        read_state_counter_strobe : out std_logic; -- strobe signal for register 'read_state_counter' (pulsed when the register is written from the bus)
        read_state_counter_value : out std_logic_vector(31 downto 0); -- write value of field 'read_state_counter.value'
        num_sweeps_pos_strobe : out std_logic; -- strobe signal for register 'num_sweeps_pos' (pulsed when the register is written from the bus)
        num_sweeps_pos_value : out std_logic_vector(31 downto 0); -- write value of field 'num_sweeps_pos.value'
        num_sweeps_pos_per_batch_strobe : out std_logic; -- strobe signal for register 'num_sweeps_pos_per_batch' (pulsed when the register is written from the bus)
        num_sweeps_pos_per_batch_value : out std_logic_vector(31 downto 0); -- write value of field 'num_sweeps_pos_per_batch.value'
        num_sweeps_neg_strobe : out std_logic; -- strobe signal for register 'num_sweeps_neg' (pulsed when the register is written from the bus)
        num_sweeps_neg_value : out std_logic_vector(31 downto 0); -- write value of field 'num_sweeps_neg.value'
        ignore_state_counter_strobe : out std_logic; -- strobe signal for register 'ignore_state_counter' (pulsed when the register is written from the bus)
        ignore_state_counter_value : out std_logic_vector(31 downto 0); -- write value of field 'ignore_state_counter.value'
        division_factor_strobe : out std_logic; -- strobe signal for register 'division_factor' (pulsed when the register is written from the bus)
        division_factor_value : out std_logic_vector(31 downto 0); -- write value of field 'division_factor.value'
        ce_strobe : out std_logic; -- strobe signal for register 'ce' (pulsed when the register is written from the bus)
        ce_value : out std_logic_vector(0 downto 0); -- write value of field 'ce.value'
	    division_factor_comm_strobe : out std_logic; -- strobe signal for register 'division_factor_comm' (pulsed when the register is written from the bus)
        division_factor_comm_value : out std_logic_vector(31 downto 0); -- write value of field 'division_factor_comm.value'
        ce_comm_strobe : out std_logic; -- strobe signal for register 'ce_comm' (pulsed when the register is written from the bus)
        ce_comm_value : out std_logic_vector(0 downto 0) -- write value of field 'ce_comm.value'
    );
end entity BRAM_write_shift_regs_wrapper;

architecture RTL of BRAM_write_shift_regs_wrapper is

	signal flip_counter_value : slv16_array_t(0 to FLIP_COUNTER_ARRAY_LENGTH-1);

begin

    -- flatten s_array_onebit into a one-dimensional vector so that:
    -- s_array_onebit[0] is mapped to s_array_onebit_slv[15 downto 0]
    -- s_array_onebit[1] is mapped to s_array_onebit_slv[31 downto 16]
    -- etc.
	
	gen2_array_value_slv : for j in 0 to FLIP_COUNTER_ARRAY_LENGTH - 1  generate
        flip_counter_value(j) <= flip_counter_value_slv((j + 1) * FLIP_COUNTER_VALUE_BIT_WIDTH - 1 downto j * FLIP_COUNTER_VALUE_BIT_WIDTH) ;
    end generate;

    BRAM_write_shift_regs_inst : entity work.BRAM_write_shift_regs
    generic map (
        AXI_ADDR_WIDTH => AXI_ADDR_WIDTH,
        BASEADDR => BASEADDR
    )
    port map(
        -- Clock and Reset
        axi_aclk    => axi_aclk,   
        axi_aresetn => axi_aresetn,
        -- AXI Write Address Channel
        s_axi_awaddr  => s_axi_awaddr, 
        s_axi_awprot  => s_axi_awprot, 
        s_axi_awvalid => s_axi_awvalid,
        s_axi_awready => s_axi_awready,
        -- AXI Write Data Channel
        s_axi_wdata   => s_axi_wdata, 
        s_axi_wstrb   => s_axi_wstrb, 
        s_axi_wvalid  => s_axi_wvalid,
        s_axi_wready  => s_axi_wready,
        -- AXI Read Address Channel
        s_axi_araddr  => s_axi_araddr, 
        s_axi_arprot  => s_axi_arprot,         
        s_axi_arvalid => s_axi_arvalid,
        s_axi_arready => s_axi_arready,
        -- AXI Read Data Channel
        s_axi_rdata   => s_axi_rdata, 
        s_axi_rresp   => s_axi_rresp, 
        s_axi_rvalid  => s_axi_rvalid,
        s_axi_rready  => s_axi_rready,
        -- AXI Write Response Channel
        s_axi_bresp   => s_axi_bresp,
        s_axi_bvalid  => s_axi_bvalid, 
        s_axi_bready  => s_axi_bready,
        -- User Ports  
		reset_tictoc_strobe => reset_tictoc_strobe,
		reset_tictoc_value => reset_tictoc_value,
		tictoc_counter_limit_strobe => tictoc_counter_limit_strobe,
		tictoc_counter_limit_value => tictoc_counter_limit_value,
		flip_counter_strobe => flip_counter_strobe,
		flip_counter_value => flip_counter_value,
		reset_ref_counter_strobe => reset_ref_counter_strobe,
		reset_ref_counter_value => reset_ref_counter_value,
		s_memory_addr => s_memory_addr,
        s_memory_rdata => s_memory_rdata,
        s_memory_ren => s_memory_ren,
        s_memory_2_addr => s_memory_2_addr,
        s_memory_2_rdata => s_memory_2_rdata,
        s_memory_2_ren => s_memory_2_ren,
		j_memory_addr => j_memory_addr,
        j_memory_wdata => j_memory_wdata,
        j_memory_wen => j_memory_wen,
        h_memory_addr => h_memory_addr,
        h_memory_wdata => h_memory_wdata,
        h_memory_wen => h_memory_wen,
	    j_read_trigger_strobe => j_read_trigger_strobe,
		j_read_trigger_value => j_read_trigger_value,
		h_read_trigger_strobe => h_read_trigger_strobe,
		h_read_trigger_value => h_read_trigger_value,
		frozen_strobe => frozen_strobe,
		frozen_value => frozen_value,
     	weight_load_done_strobe => weight_load_done_strobe,
		weight_load_done_value => weight_load_done_value,
        active_state_counter_strobe => active_state_counter_strobe,
        active_state_counter_value => active_state_counter_value,
        read_state_counter_strobe => read_state_counter_strobe,
        read_state_counter_value => read_state_counter_value,
        ignore_state_counter_strobe => ignore_state_counter_strobe,
        ignore_state_counter_value => ignore_state_counter_value,
        num_sweeps_pos_strobe => num_sweeps_pos_strobe,
        num_sweeps_pos_value => num_sweeps_pos_value,
        num_sweeps_pos_per_batch_strobe => num_sweeps_pos_per_batch_strobe,
        num_sweeps_pos_per_batch_value => num_sweeps_pos_per_batch_value,
        num_sweeps_neg_strobe => num_sweeps_neg_strobe,
        num_sweeps_neg_value => num_sweeps_neg_value,
        division_factor_strobe => division_factor_strobe,
		division_factor_value => division_factor_value,
     	ce_strobe => ce_strobe,
		ce_value => ce_value,
	    division_factor_comm_strobe => division_factor_comm_strobe,
		division_factor_comm_value => division_factor_comm_value,
     	ce_comm_strobe => ce_comm_strobe,
		ce_comm_value => ce_comm_value

		

		

		
    );

end architecture RTL;    