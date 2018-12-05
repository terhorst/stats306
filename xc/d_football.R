## Gameplay code

library(microbenchmark)

TEAMS <- c("michigan", "ohio")

new_game <- function(n) {
    # construct a new game and return the result game object, which is a list
    # with two entries: the board, and whose turn it is.
    # the board encodes michigan as 1 and ohio as -1. empty squares are encoded as 0.
    list(board = c(rep(1, n), 0, rep(-1, n)),
         turn = 1)
}

whose_turn <- function(game) TEAMS[game$turn]

lead <- function(v, k=1) {
    c(v[(k + 1):length(v)], rep(NA, k))
}

valid_moves <- function(game) {
    # return a list of the valid moves for this game
    b <- game$board
    if (game$turn == -1) 
        # if it's Ohio's turn to move, we "flip" the board around, compute
        # the valid moves for michigan, and then mirror those positions back
        return(length(b) + 1L - valid_moves(list(board=-1 * rev(b), turn = 1)))
    which(
        # square is occupied my UM player AND either
        (b == 1) & (
            # the square to the right is empty OR
            (lead(b) == 0) |  
            # the square to the right is an Ohio player, 
            # and the square two to the right is empty
            (lead(b) == -1) & (lead(b, 2) == 0) 
        )
    )
}

make_move <- function(game, move) {
    # make a move and return the new game board
    # if the move is not valid, throw an error
    stopifnot(move %in% valid_moves(game))
    t <- game$turn
    b <- game$board
    b[move] <- 0
    if (b[move + t] == 0) {
        # the adajacent square is empty.
        b[move + t] <- t
        lm <- c(move, move + t)
    } else {
        # the adjacent square has an opposing player, and the square adjacent to it is empty.
        b[move + t] <- 0
        b[move + 2 * t] <- t
        lm <- c(move, move + t, move + 2 * t)
    }
    game <- list(board = b, turn = -1 * t, last_move = lm)
}

check_for_winner <- function(game) {
    teams <- stringr::str_to_title(TEAMS)
    v <- valid_moves(game)
    if (length(v) == 0) {
        t <- teams[[game$turn]]
        t2 <- teams[[-game$turn]]
        stop(
            paste(t, "cannot move.", t2, "wins!")
        )
    }
}

normalize_game <- function(game) {
    # return an equivalent game in which it is Michigan's turn to move
    if (game$turn == 1) {
        game
    } else {
        list(board=-rev(game$board), turn = 1)
    }
}

num_pieces <- function(game) list(michigan = sum(game$board) == 1,
                                  ohio = sum(game$board == -1))

num_ohio <- function(game) num_pieces(game)$ohio

.play_game <- function(mi_strategy, oh_strategy, n = 5, disp = F) {
    # play a game between strategy1 and strategy2. 
    # return the winner of the game
    g <- new_game(n)
    if (disp) {
        if (n > 5) {
            warning("Refusing to display output for n > 5")
            disp <- F
        } else 
            print_game(g)
    }
    strats <- list(list(s=mi_strategy, env=new.env()), 
                   list(s=oh_strategy, env=new.env()))
    while (length(valid_moves(g)) > 0) {
        st <- strats[[g$turn]]
        ng <- normalize_game(g)
        t0 <- microbenchmark::get_nanotime()
        m <- try(eval(st$s(ng), envir=st$env))
        if (inherits(m, "try-error")) {
            warning(paste0(TEAMS[[g$turn]], " strategy produced an error"))
            break
        }
        t1 <- microbenchmark::get_nanotime() 
        if (t1 - t0 > 1e8) {
            warning(paste0(TEAMS[[g$turn]], " strategy took >100ms to return a move"))
            break
        }    
        if (length(m) != 1 || ! m %in% valid_moves(ng)) {
            warning(paste0(TEAMS[[g$turn]], " strategy returned an invalid move"))
            break
        }
        if (g$turn == -1) 
            m <- 2 * n + 2 - m
        g <- make_move(g, m)
        if (disp)
            print_game(g)
    }
    -g$turn
}

play_game <- function(...) TEAMS[[.play_game(...)]]

play_repeatedly <- function(strategy1, strategy2, k = 100, n = 5) {
    # play 2 * k games against each other, where each strategy moves first
    # k times.
    # return a vector of (1, 2) indicating which strategy won each time.
    res <- c(
        sapply(1:k, function(.) .play_game(strategy1, strategy2, n)),
        -sapply(1:k, function(.) .play_game(strategy2, strategy1, n))
    )
    c("strategy1" = sum(res == 1), "strategy2" = sum(res == -1))
}

## Printing code
# This code outputs an HTML representation of the game, the value moves,
# the current turn, etc. This code requires Jupyter notebook to work.
library(xml2)
print_game <- function(game) {
    v <- valid_moves(game)
    b <- game$board
    cls_map <- list("1" = "michigan", "0" = "empty", "-1" = "ohio")
    # a bunch of gross HTML stuff
    x <- xml_new_document()
    s <- xml_add_child(x, 'style')
    xml_text(s) <- "@import url(css/rb.css);"
    xml_set_attr(s, "type", "text/css")
    p <- xml_add_sibling(s, "h3")
    xml_set_attr(p, "class", "turn")
    tm <- cls_map[[as.character(game$turn)]]
    sp <- xml_add_child(p, "span")
    xml_set_text(sp, stringr::str_to_title(tm))
    xml_set_attr(sp, "class", tm)
    sp <- xml_add_child(p, "span")
    if (length(v) > 0) {
        xml_set_text(sp, " to move")
    } else {
        xml_set_text(sp, " loses!")
    }
    t <- xml_add_sibling(p, 'table')
    xml_set_attr(t, "class", "board")
    tr <- xml_add_child(t, 'tr')
    xml_set_attr(tr, "class", "players")
    tr2 <- xml_add_sibling(tr, "tr")
    xml_set_attr(tr2, "class", "numbers")
    for (i in seq_along(b)) {
        td <- xml_add_child(tr, "td")
        cls <- cls_map[[as.character(b[[i]])]]
        td2 <- xml_add_child(tr2, "td")
        xml_set_text(td2, as.character(i))
        if (i %in% v) {
            xml_set_attr(td2, "class", "valid")
        }
        lm <- game$last_move
        if (i %in% game$last_move) {
            cls <- c(cls, "last")
            if (! (i %in% c(min(lm), max(lm)))) {
                cls <- c(cls, 
                         paste0(
                             cls_map[[as.character(-b[[i - game$turn]])]],
                             "-faint"
                             )
                         )
            }
        }
        xml_set_attr(td, "class", paste(cls, collapse=" "))
    }
    IRdisplay::display_html(as.character(x))
}
