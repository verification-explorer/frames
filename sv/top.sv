package pkg_lib;

    typedef struct { rand int x; rand int y;} coordinate;

    class coordinates;

        parameter M=16;
        parameter N=16;

        bit mtrx[M][N];
        coordinate coordinates_list[$] = '{
            '{0,0},'{1,1},'{2,2},'{3,3},'{4,4},'{5,5},'{6,6},'{7,7},'{8,8},
            '{15,15},'{14,14},'{13,13},'{12,12},'{11,11},'{10,10},'{9,9},
            '{15,0},'{14,1},'{13,2},'{12,3},'{11,4},'{10,5},'{9,6},
            '{6,9},'{5,10},'{4,11},'{3,12},'{2,13},'{1,14},'{0,15},
            '{7,8},'{8,7}
        };

        function void post_randomize();
            foreach(mtrx[i,j]) begin
                mtrx[i][j]=0;
            end

            foreach (coordinates_list[i]) begin
                mtrx[coordinates_list[i].y][coordinates_list[i].x]=1;
            end
        endfunction : post_randomize

    endclass

    class frame;

        parameter M=16;
        parameter N=16;

        bit mtrx [M][N];

        rand bit [(M-1):0] m;
        rand bit [(M-1):0] m0;
        rand bit [(N-1):0] n;
        rand bit [(N-1):0] n0;
        rand bit [(M-1):0] h_skip;
        rand bit [(N-1):0] v_skip;


        rand int help_mtrx_x[];
        rand int help_mtrx_y[];
        coordinate coordinates_list[$];

        constraint first_index_c {
            m0 inside {[0:(M-1)]};
            n0 inside {[0:(N-1)]};
        }

        constraint skip_c {
            h_skip inside {[2:(M-1)]};
            v_skip inside {[2:(N-1)]};
        }

        constraint mtrx_size_c {
            m inside {[2:(M-1)]};
            n inside {[2:(N-1)]};
        }

        constraint row_grid_c {
            m + ((m-1) * v_skip) < ((M-1) - m0);
        }

        constraint col_grid_c {
            n + ((n-1) * h_skip) < ((N-1) - n0);
        }

        constraint help_mtrx_x_c {
            help_mtrx_x.size==n;
            foreach(help_mtrx_x[i]) {
                help_mtrx_x[i] == n0 + (i * h_skip);
            }
        }

        constraint help_mtrx_y_c {
            help_mtrx_y.size==m;
            foreach(help_mtrx_y[i]) {
                help_mtrx_y[i] == m0 + (i * v_skip);
            }
        }

        constraint intersect_c {
            foreach (help_mtrx_x[i]) {
                foreach (help_mtrx_y[j]) {
                    foreach (coordinates_list[k]) {

                        // Cantor Pairing Function
                        (help_mtrx_x[i] + help_mtrx_y[j]) *
                        (help_mtrx_x[i] + help_mtrx_y[j] + 1) / 2 +
                        help_mtrx_y[j] !=
                        (coordinates_list[k].x + coordinates_list[k].y) *
                        (coordinates_list[k].x + coordinates_list[k].y + 1) / 2 +
                        coordinates_list[k].y;
                    }
                }
            }
        }

        function void pre_randomize();
            foreach (mtrx[i,j]) begin
                mtrx[i][j]=0;
            end
        endfunction : pre_randomize

        function void post_randomize();
            int h=m0;
            int v=n0;
            for (int i=0; i<n ; i++) begin
                for (int j=0; j<m; j++) begin
                    mtrx[h][v]=1;
                    h+=v_skip;
                end
                h=m0;
                v+=h_skip;
            end
        endfunction

        function string convert2string();
            string s="";
            $sformat(s,"%s m0: %0d\n",s,m0);
            $sformat(s,"%s n0: %0d\n",s,n0);
            $sformat(s,"%s m: %0d\n",s,m);
            $sformat(s,"%s n: %0d\n",s,n);
            $sformat(s,"%s h_skip: %0d\n",s,h_skip);
            $sformat(s,"%s v_skip: %0d\n",s,v_skip);
            return s;
        endfunction


        function void print ();
            string str;
            string s={4{" "}};
            foreach (mtrx[i]) begin
                $sformat(s, "%s%0d%s ", s, i, {3{" "}});
            end
            $sformat(s, "%s\n",s);
            for (int i = 0; i<M; i++) begin
                if (i<10) begin
                    $sformat(s, "%s%0d%s", s,i,{3{" "}});
                end else begin
                    $sformat(s, "%s%0d%s", s,i,{2{" "}});
                end
                for (int j = 0 ; j<N; j++) begin
                    string chr;
                    if (mtrx[i][j]) begin
                        chr="P";
                        foreach(coordinates_list[k]) begin
                            if (coordinates_list[k].x==j && coordinates_list[k].y==i) chr="F";
                        end
                    end else begin
                        chr=" ";
                        foreach(coordinates_list[k]) begin
                            if (coordinates_list[k].x==j && coordinates_list[k].y==i) chr="x";
                        end
                    end
                    if (j<(N-1)) begin
                        if (j<10) begin
                            $sformat(s,"%s[%s]%s",s,chr,{2{" "}});
                        end else begin
                            $sformat(s,"%s[%s]%s",s,chr,{3{" "}});
                        end
                    end else begin
                        $sformat(s,"%s[%s]%s\n",s,chr,{2{" "}});
                    end
                end
            end
            $display(s);
        endfunction

        function void qprint();
            foreach (coordinates_list[i]) $display("[%0d,%0d]",coordinates_list[i].y,coordinates_list[i].x);
        endfunction

        function void print_mtrx_x();
            for (int i=0; i<help_mtrx_x.size; i++) begin
                $display("mtrx_x[%0d]: %0d",i,help_mtrx_x[i]);
            end
        endfunction

        function void print_mtrx_y();
            for (int i=0; i<help_mtrx_y.size; i++) begin
                $display("mtrx_y[%0d]: %0d",i,help_mtrx_y[i]);
            end
        endfunction


    endclass

endpackage

module top;

    import pkg_lib::*;

    frame       frm;
    coordinates cor;

    initial begin
        bit ok;
        cor=new;
        frm=new;
        repeat (1) begin
            ok=cor.randomize();
            frm.coordinates_list=cor.coordinates_list;
            ok=frm.randomize();
            frm.print();
        end
        $finish;
    end
endmodule
