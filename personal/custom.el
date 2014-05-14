(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes (quote ("cd70962b469931807533f5ab78293e901253f5eeb133a46c2965359f23bfb2ea" "d677ef584c6dfc0697901a44b885cc18e206f05114c8a3b7fde674fce6180879" default)))
 '(gnus-alias-identity-rules (quote (("personal" ("any" "wael.nasreddine@gmail.com" both) "personal") ("work" ("any" "\\(wmn\\|wnasreddine\\)@google.com" both) "work"))))
 '(mail-envelope-from (quote header))
 '(mail-specify-envelope-from t)
 '(message-kill-buffer-on-exit t)
 '(message-sendmail-envelope-from (quote header))
 '(notmuch-fcc-dirs nil)
 '(send-mail-function (quote sendmail-send-it))
 '(sendmail-program "/usr/bin/msmtp"))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; Prelude install packages
(prelude-require-packages '(notmuch notmuch-labeler 2048-game w3m))

;; Modules

;; Emacs IRC client
(require 'prelude-erc)
(require 'prelude-ido) ;; Super charges Emacs completion for C-x C-f and more
(require 'prelude-helm) ;; Interface for narrowing and search
(require 'prelude-company)
;; (require 'prelude-key-chord) ;; Binds useful features to key combinations
;; (require 'prelude-mediawiki)
;; (require 'prelude-evil)

;;; Programming languages support
(require 'prelude-c)
;; (require 'prelude-clojure)
;; (require 'prelude-coffee)
;; (require 'prelude-common-lisp)
;; (require 'prelude-css)
(require 'prelude-emacs-lisp)
;; (require 'prelude-erlang)
;; (require 'prelude-haskell)
(require 'prelude-js)
;; (require 'prelude-latex)
(require 'prelude-lisp)
(require 'prelude-org) ;; Org-mode helps you keep TODO lists, notes and more
;; (require 'prelude-perl)
(require 'prelude-python)
(require 'prelude-ruby)
;; (require 'prelude-scala)
(require 'prelude-scheme)
(require 'prelude-shell)
;; (require 'prelude-scss)
(require 'prelude-web) ;; Emacs mode for web templates
(require 'prelude-xml)

;; Set the default browser to Chrome
(setq browse-url-browser-function 'browse-url-generic
      browse-url-generic-program "google-chrome-beta")

;;
;; Notmuch
;;

;; Sign messages by default.
(add-hook 'message-setup-hook 'mml-secure-sign-pgpmime)

;; style a few lables
(require 'notmuch-labeler)
(setq notmuch-saved-searches '(
                               (:name "inbox-work-new" :query "tag:work AND tag:unread AND tag:inbox")
                               (:name "inbox-personal-new" :query "tag:personal AND tag:unread AND tag:inbox")
                               (:name "work-new" :query "tag:work AND tag:unread")
                               (:name "personal-new" :query "tag:personal AND tag:unread")
                               (:name "work" :query "tag:work")
                               (:name "personal" :query "tag:personal")
                               (:name "inbox-unread" :query "tag:inbox AND tag:unread")
                               (:name "unread" :query "tag:unread")
                               (:name "inbox" :query "tag:inbox")
                               ))

(notmuch-labeler-rename "work" "work" ':foreground "red")
(notmuch-labeler-rename "personal" "personal" ':foreground "blue")

;; At startup position the cursor on the first saved searches
(add-hook 'notmuch-hello-refresh-hook
          (lambda ()
            (if (and (eq (point) (point-min))
                     (search-forward "Saved searches:" nil t))
              (progn
                (forward-line)
                (widget-forward 1))
              (if (eq (widget-type (widget-at)) 'editable-field)
                (beginning-of-line)))))

;; Toggle message deletion
(define-key notmuch-show-mode-map "d"
  (lambda ()
    "toggle deleted tag for message"
    (interactive)
    (if (member "deleted" (notmuch-show-get-tags))
        (notmuch-show-tag (list "-deleted"))
      (notmuch-show-tag (list "+deleted")))))

;; Mark as a Spam
(define-key notmuch-show-mode-map "!"
  (lambda ()
    "toggle spam tag for message"
    (interactive)
    (if (member "spam" (notmuch-show-get-tags))
        (notmuch-show-tag (list "-spam"))
      (notmuch-show-tag (list "+spam")))))

;; Kill a thread
(define-key notmuch-show-mode-map "&"
  (lambda ()
    "toggle killed tag for message"
    (interactive)
    (if (member "killed" (notmuch-show-get-tags))
        (notmuch-show-tag (list "-killed"))
      (notmuch-show-tag (list "+killed")))))

;; Bounce a message
(define-key notmuch-show-mode-map "b"
  (lambda (&optional address)
    "Bounce the current message."
    (interactive "sBounce To: ")
    (notmuch-show-view-raw-message)
    (message-resend address)))

;; reply to all by default
(define-key notmuch-show-mode-map "r" 'notmuch-show-reply)
(define-key notmuch-show-mode-map "R" 'notmuch-show-reply-sender)

(define-key notmuch-search-mode-map "r" 'notmuch-search-reply-to-thread)
(define-key notmuch-search-mode-map "R" 'notmuch-search-reply-to-thread-sender)

;; Multiple identities
(require 'gnus-alias)
(setq gnus-alias-identity-alist
      '(("personal"
         nil ;; Does not refer to any other identity
         "Wael Nasreddine <wael.nasreddine@gmail.com>" ;; Sender address
         nil ;; No organization header
         nil ;; No extra headers
         nil ;; No extra body text
         "~/.signature")
        ("work"
         nil
         "Wael Nasreddine <wmn@google.com>" ;; Sender address
         "Google"
         nil
         nil
         "~/.signature.work")))
;; Use "home" identity by default
(setq gnus-alias-default-identity "work")
;; Determine identity when message-mode loads
(add-hook 'message-setup-hook 'gnus-alias-determine-identity)

;; ERC
(require 'erc)
(erc-autojoin-mode t)
(setq erc-autojoin-channels-alist
      '((".*\\.freenode.net" "#test")))
      ;'((".*\\.freenode.net" "#notmuch")
        ;(".*\\.corp.google.com" "#ci" "#ci-oncall")))

;; check channels
(erc-track-mode t)
(setq erc-track-exclude-types '("JOIN" "NICK" "PART" "QUIT" "MODE"
                                 "324" "329" "332" "333" "353" "477"))
;; don't show any of this
(setq erc-hide-list '("JOIN" "PART" "QUIT" "NICK"))

;; load the passwords
(load "~/.ercpass")

;; don't prompt for nickserv password
(setq erc-prompt-for-nickserv-password nil)

;; Start or switch to ERC
(defun erc-start-or-switch ()
  "Connect to ERC, or switch to last active buffer"
  (interactive)
  (if (get-buffer "irc.freenode.net:6667") ;; ERC already active?

    (erc-track-switch-buffer 1) ;; yes: switch to last active
    (when (y-or-n-p "Start ERC? ") ;; no: maybe start ERC
      (erc :server "irc.freenode.net" :port 6667 :nick "eMxyzptlk" :full-name "Wael Nasreddine" :password freenode-nick-pass)
      (erc-tls :server "irc.corp.google.com" :port 6697 :nick "wmn" :full-name "Wael Nasreddine" :password corp-nick-pass))))

;; switch to ERC with Ctrl+c e
(global-set-key (kbd "C-c C-e") 'erc-start-or-switch) ;; ERC
