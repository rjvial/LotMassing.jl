function plotCabidaOptima(setCeldasActivas, pisoActivoCeldas, pos_x, pos_y, largo_x, largo_y, R, r, dca, fig_, ax_, ax_mat_)

    global fig, ax, ax_mat

    fig=fig_; ax=ax_; ax_mat=ax_mat_;
    for j in setCeldasActivas

        p1_vec_ = (R[r].mat * ([pos_x[j]'; pos_y[j]'] - R[r].cr) + R[r].cr)';
        p2_vec_ = (R[r].mat * ([pos_x[j]' + largo_x[j,r]'; pos_y[j]'] - R[r].cr) + R[r].cr)';
        p3_vec_ = (R[r].mat * ([pos_x[j]' + largo_x[j,r]'; pos_y[j]' + largo_y[j,r]'] - R[r].cr) + R[r].cr)';
        p4_vec_ = (R[r].mat * ([pos_x[j]'; pos_y[j]' + largo_y[j,r]'] - R[r].cr) + R[r].cr)';

        V_tapa = [p1_vec_; p2_vec_; p3_vec_; p4_vec_]
        for k = 1:round(sum(pisoActivoCeldas[j,:]))
            V_edif = [[p1_vec_ dca.ALTURAPISO * (k - 1)];
                  [p2_vec_ dca.ALTURAPISO * (k - 1)];
                  [p3_vec_ dca.ALTURAPISO * (k - 1)];
                  [p4_vec_ dca.ALTURAPISO * (k - 1)];
                  [p1_vec_ dca.ALTURAPISO * k];
                  [p2_vec_ dca.ALTURAPISO * k];
                  [p3_vec_ dca.ALTURAPISO * k];
                  [p4_vec_ dca.ALTURAPISO * k] ]
            fig, ax, ax_mat = polyShape.plotPolyshape3d_v2(PolyShape([V_edif],1), dca.ALTURAPISO * (k - 1), fig, ax, ax_mat, "teal", 1)
            fig, ax, ax_mat = polyShape.plotPolyshape3d_v2(PolyShape([V_tapa],1), dca.ALTURAPISO * k, fig, ax, ax_mat, "teal", 1)
        end

    end

    return fig, ax, ax_mat

end