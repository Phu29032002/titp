module tb_fsm_vending;	
	logic clk;
    logic reset_n;
    logic start;
    logic done_money;
    logic cancel;
    logic continue_buy;
    logic [1:0] item_in;
    logic [2:0] money;
    logic deno_5;
    logic deno_10;
    logic deno_20;
    logic done;
    logic end_trans;
    logic [7:0] price;
    logic [7:0] sum_money;
    logic [1:0] item_select;
    logic [2:0] state;

    // Instantiate the Unit Under Test (UUT)
    control uut_control (
        .clk(clk),
        .reset_n(reset_n),
        .start(start),
        .done_money(done_money),
        .cancel(cancel),
        .continue_buy(continue_buy),
        .item_in(item_in),
        .money(money),
        //.deno_5(deno_5),
        //.deno_10(deno_10),
        //.deno_20(deno_20),
        .done(done),
        .end_trans(end_trans),
        .price(price),
        .sum_money(sum_money),
        .item_select(item_select),
        .state(state)
    );

    fsm uut_fsm(
        //.state(state)
    );

    parameter IDLE = 3'd0;
    parameter SELECT = 3'd1;
    parameter RECEIVE_MONEY = 3'd2;
    parameter COMPARE = 3'd3;
    parameter PROCESS = 3'd4;
    parameter RETURN_CHANGE = 3'd5;

    initial begin 
        clk=0;
        forever begin
            #5 clk = ~clk;
        end
    end
    
    initial begin
    start = 0;
    done_money = 0;
    cancel = 0;
    continue_buy = 0;
    item_in = 0;
    money = 0;
    //deno_5 = 0;
    //deno_10 = 0;
    //deno_20=0;

    end

    task cmp;
        input [7:0] a;
        input [7:0] b;
        begin
            if (a == b) begin
                $display("Test Passed");
            end
            else begin
                $display("Test Failed");
            end
        end
    endtask

    task reset;
        begin
            reset_n = 0;
            #5 reset_n = 1;
            #1;
            $display("          =======RESET TEST===========            ");
            if(uut_control.state == IDLE ) begin
                    if(!end_trans && !done && !sum_money && !price && !item_select) begin
                        $display("time: %d | PASSED", $time);
                    end
                    else begin
                        $display("time: %d | FAILED: end_trans = %b | done = %b | sum_money = %b | price = %b | item_slect = %b | next_state = %d", $time, end_trans, done, sum_money, price, item_select, uut_control.state);
                    end    
               end
        end
    endtask

task reset_without_check;
    begin
        reset_n = 0;
        start = 0;
        done_money = 0;
        cancel = 0;
        continue_buy = 0;
        item_in = 0;
        money = 0;       
        #5 reset_n = 1;
    end

endtask
task STATE_check;
    input [2:0] task_state;
    input task_end_trans;
    input task_done;
    input [7:0] task_sum_money;
    input [7:0] task_price;
    input [1:0] task_item_select;
    begin
        if(uut_control.state == task_state) begin
            if(task_end_trans == end_trans && task_done == done && task_sum_money == sum_money && task_price == price && task_item_select == item_select) begin
                $display("time: %d | PASSED", $time);
            end
            else begin 
                $display("time: %d | FAILED: end_trans = %b | done = %b | sum_money = %b | price = %b | item_slect = %b | next_state = %d", $time, end_trans, done, sum_money, price, item_select, uut_control.state);
            end
        end
        else begin
            $display("time: %d | FAILED: next_state = %d", $time, uut_control.state);
        end
    end
endtask

// cover IDLE state to SELECT state 
    task IDLE_check;
        input task_start;
        begin
            start = task_start;
            @(posedge clk);
            //done_money = $random;
            //cancel = $random;
            //continue_buy = $random;
            //item_in = $random;
            //money = $random;
            #1;
            if(task_start == 1) begin // IDLE state to SELECT state
                $display("          =======case IDLE check start = 1=======         ");
               if(uut_control.state == SELECT ) begin
                    if(!end_trans && !done && !sum_money && !price && !item_select) begin
                        $display("time: %d | PASSED", $time);
                    end
                    else begin
                        $display("time: %d | FAILED: end_trans = %b | done = %b | sum_money = %b | price = %b | item_slect = %b | next_state = %d", $time, end_trans, done, sum_money, price, item_select, uut_control.state);
                    end    
               end
               else begin
                        $display("time: %d | FAILED: end_trans = %b | done = %b | sum_money = %b | price = %b | item_slect = %b | next_state = %d", $time, end_trans, done, sum_money, price, item_select, uut_control.state);
               end
            end
            else begin
                if(task_start == 0) begin // IDLE state to IDLE state
                    $display("          =======case IDLE check start = 0========        ");
                    if(uut_control.state == IDLE ) begin
                            if(!end_trans && !done && !sum_money && !price && !item_select) begin
                                $display("time: %d | PASSED", $time);
                            end
                            else begin
                                $display("time: %d | FAILED: end_trans = %b | done = %b | sum_money = %b | price = %b | item_slect = %b | next_state = %d", $time, end_trans, done, sum_money, price, item_select, uut_control.state);
                            end    
                    end
                    else begin
                                $display("time: %d | FAILED: end_trans = %b | done = %b | sum_money = %b | price = %b | item_slect = %b | next_state = %d", $time, end_trans, done, sum_money, price, item_select, uut_control.state);
                    end
                end   
            end
        end
    endtask



    task SELECT_check; //SELECT to RECEIVE_MONEY 
        input cancel_task;
        input [1:0] item_in_task;
        begin
            start = 1;
            cancel = cancel_task;
            item_in = item_in_task;
            @(posedge clk);
            @(posedge clk);
            #1;
            case({cancel, uut_fsm.out_stock})
                2'b00: begin
                    $display("         =======case SELECT check cancel = 0 out_stock = 0 ========        ");
                    STATE_check(RECEIVE_MONEY, 0, 0, 0, 0, 0);
                end
                2'b01: begin
                    $display("         =======case SELECT check cancel = 0 out_stock = 1 ========        ");
                    STATE_check(SELECT, 0, 0, 0, 0, 0);
                end
                2'b10: begin
                    $display("         =======case SELECT check cancel = 1 out_stock = 0 ========        ");
                    //STATE_check(IDLE,end_trans , done, sum_money, price, item_select);
                    STATE_check(IDLE, 0, 0, 0, 0, 0);
                end
                2'b11: begin
                    $display("         =======case SELECT check cancel = 1 and out_stock = 1 ========        ");
                    STATE_check(IDLE, 0, 0, 0, 0, 0);
                end
                //default:
            endcase
        end
    endtask
    
    task COMPARE_check;
        begin
            start = 1; //IDLE
            cancel = 0;
            item_in = 2'b00;
            @(posedge clk);//SELECT
            @(posedge clk);
            money = 3'b001;
            done_money = 1;
            @(posedge clk);
            @(posedge clk);
            #1;
            case(uut_fsm.enough_money)
                1'b0: begin
                    $display("         =======case COMPARE check enough_money = 0 ========        ");
                    STATE_check(PROCESS, 0, 0, 0, 0, 0);
                end
                1'b1: begin
                    $display("         =======case COMPARE check enough_money = 1 ========        ");
                    //STATE_check(RETURN_CHANGE, 0, 0, 0, 0, 0);
                    if(uut_control.state == RETURN_CHANGE) begin
                        $display("time: %d | PASSED", $time);
                    end
                    else begin
                        $display("time: %d | FAILED: next_state = %d | EXPECT: next_state = %d", $time, uut_control.state,RETURN_CHANGE );
                    end
                end
                default: begin
                    $display("time: %d | FAILED: enough_money = %b", $time, uut_fsm.enough_money);
                end
            endcase
        end
    endtask

    task PROCESS_check;
    input cancel_task;
        begin
            start = 1; //IDLE
            cancel = 0;
            @(posedge clk);//SELECT
            item_in = $urandom_range(0, 3);
            @(posedge clk);// RECEIVE
            money = $urandom_range(1, 8);
            done_money = 1;
            @(posedge clk);//COMPARE
            @(posedge clk);//PROCESS
            cancel = cancel_task;
            @(posedge clk);
            #1;
            case(cancel)
                1'b0: begin
                    $display("         =======case PROCESS check cancel = 0 ========        ");
                    STATE_check(RECEIVE_MONEY, 0, 0, 0, 0, 0);
                end
                1'b1: begin
                    $display("         =======case PROCESS check cancel = 1 ========        ");
                    //STATE_check(RETURN_CHANGE, 0, 0, 0, 0, 0);
                    if(uut_control.state == RETURN_CHANGE) begin
                        $display("time: %d | PASSED", $time);
                    end
                    else begin
                        $display("time: %d | FAILED: next_state = %d", $time, uut_control.state);
                    end
                end
                default: begin
                    $display("time: %d | FAILED: enough_money = %b", $time, uut_fsm.enough_money);
                end
            endcase            
        end

    endtask
    logic [7:0] sum = 0;
    task RETURN_CHANGE_check;
        input continue_buy_task;
        input item_select_task;
        begin
            start = 1; //IDLE
            cancel = 0;
            done_money = 0;
            @(posedge clk);//SELECT
            
            item_in = item_select_task;
            @(posedge clk);// RECEIVE
            money = 3'b100;
            sum += money;
            @(posedge clk); //WAIT
            money = 3'b010;
            sum += money;
            done_money = 1;
            @(posedge clk);//COMPARE
            @(posedge clk);
            continue_buy = continue_buy_task;
            $display("         =======Check output========        ");
            if(done && end_trans && (sum_money==sum) && price == uut_fsm.pop[1] && item_select) begin
                 $display("time: %d | PASSED", $time);  
            end
            else begin
                $display("time: %d | FAILED: end_trans = %b | done = %b | sum_money = %b | price = %b | item_slect = %b ", $time, end_trans, done, sum_money, price, item_select);
            end
            @(posedge clk);
            #1;

            if(continue_buy_task == 1) begin
                $display("         =======case RETURN_CHANGE check continue_buy = 1 ========        ");
                STATE_check(SELECT, 0, 0, 0, 0, 0);
            end
            else begin
                $display("         =======case RETURN_CHANGE check continue_buy = 0 ========        ");
                STATE_check(IDLE, 0, 0, 0, 0, 0);
            end
        end
    endtask




    initial begin
        reset;
        IDLE_check(0);
        IDLE_check(1);
        @(posedge clk);
        reset;
        //$display("case SELECT check cancel = 1 and item_in = 0");
        SELECT_check(1, 2'b00);
        @(posedge clk);
        reset_without_check;
        SELECT_check(0, 2'b01);
        @(posedge clk);
        reset_without_check;
        COMPARE_check;
        @(posedge clk);
        reset_without_check;
        PROCESS_check(0);
        @(posedge clk);
        reset_without_check;
        PROCESS_check(1);        
        @(posedge clk);
        reset_without_check;
        RETURN_CHANGE_check(0,2'b01);
        @(posedge clk);
        reset_without_check;
        RETURN_CHANGE_check(1,2'b00);
        reset_without_check;
        RETURN_CHANGE_check(1,2'b10);
        reset_without_check;
        RETURN_CHANGE_check(1,2'b11);
    end
   
   initial begin
    $monitor("time : %d | enough_money = %b", $time, uut_fsm.enough_money);
   end

endmodule
