;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;;
;;

(setq fancy-splash-image "~/Pictures/output2.png")
(remove-hook '+doom-dashboard-functions #'doom-dashboard-widget-shortmenu)

(defvar +doom-dashboard-banner-padding '(0 . 1))

(defvar +doom-dashboard-quotes
  '("Are you okay with staying weak?"
    "I guess it comes down to a simple choice, really. You get busy living, or get busy dying."
    ;; "I guess it comes down to a simple choice, really. You get busy living, or get busy dying. —Andy Dufresne in The Shawshank Redemption"
    ;;     "I must not fear.
    ;; Fear is the mind-killer.
    ;; Fear is the little-death that brings total obliteration.
    ;; I will face my fear.
    ;; I will permit it to pass over me and through me.
    ;; And when it has gone past, I will turn the inner eye to see its path.
    ;; Where the fear has gone there will be nothing. Only I will remain."
    ;;     "I went to the woods because I wished to live deliberately... I wanted to live deep and suck out all the marrow of life... \n to put rout all that was not life; and not, when I came to die, discover that I had not lived."
    ;; Add more quotes here
    ))

(defun doom-dashboard-widget-footer ()
  (insert
   "\n"
   (+doom-dashboard--center
    (- +doom-dashboard--width 1)
    (concat (nth (random (length +doom-dashboard-quotes))
                 +doom-dashboard-quotes)
            "\n"))))

(use-package circadian
  :ensure t
  :config
  (setq circadian-themes '(("8:00" . doom-one)
                           ("19:30" . doom-gruvbox)))
  (circadian-setup))



;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

(use-package all-the-icons
  :if (display-graphic-p))

;; org configurations
(use-package! org
  :config
  ;; ORG LATEX PREVIEW
  (setq
   org-startup-with-latex-preview t
   ;; Make latex preview with "C-c C-x C-l" slightly bigger
   org-format-latex-options
   (plist-put org-format-latex-options
              :scale 1.7)
   ;; Cache the preview images elsewhere
   org-preview-latex-image-directory "~/.cache/ltximg/"
   org-highlight-latex-and-related nil
   org-image-actual-width (/ (display-pixel-width) 3))
  ;; Custom some face
  (custom-set-faces!
    '((org-block-begin-line org-block-end-line)
      :slant italic)
    '((org-document-title)
      :height 1.5))
  )

;; hide emphasis markers:
(setq org-hide-emphasis-markers t)

(use-package! websocket
  :after org-roam)

(use-package! org-roam
  :after org
  :init
  (setq +org-roam-open-buffer-on-find-file nil
        org-roam-directory "~/RoamNotes"
        org-roam-dailies-directory "journal/"
        org-roam-mode-section-functions
        (list #'org-roam-backlinks-section
              #'org-roam-reflinks-section
              #'org-roam-unlinked-references-section)
        hp/org-roam-function-tags '("compilation" "argument" "journal" "concept" "tool" "data" "bio" "literature" "event" "website"))
  (add-to-list 'magit-section-initial-visibility-alist
               '(org-roam-unlinked-references-section . hide))
  :custom
  (org-roam-dailies-capture-templates
   '(("d" "default" plain (file "~/Templates/timeblock.org")
      :if-new (file+head "%<%Y-%m-%d>.org" "#+title: %<%Y-%m-%d>\n")
      )))

  (org-roam-capture-templates
   '(
     ("r" "research" plain "%?"
      :target (file+head "research/%<%Y%m%d%H%M%S>-${slug}.org"
                         "#+title: ${title}\n") :unnarrowed t)
     ("c" "climbing" plain "%?"
      :target (file+head "climbing/%<%Y%m%d%H%M%S>-${slug}.org"
                         "#+title: ${title}\n") :unnarrowed t)
     ("p" "productivity" plain "%?"
      :target (file+head "productivity/%<%Y%m%d%H%M%S>-${slug}.org"
                         "#+title: ${title}\n") :unnarrowed t)
     ("s" "school" plain "%?"
      :target (file+head "school/%<%Y%m%d%H%M%S>-${slug}.org"
                         "#+title: ${title}\n") :unnarrowed t)
     ("d" "default" plain "%?"
      :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                         "#+title: ${title}\n") :unnarrowed t)
     )
   )

  :bind (("C-c t" . org-roam-dailies-capture-today))
  :config
  ;; Org-roam interface
  (cl-defmethod org-roam-node-hierarchy ((node org-roam-node))
    "Return the node's TITLE, as well as it's HIERACHY."
    (let* ((title (org-roam-node-title node))
           (olp (mapcar (lambda (s) (if (> (length s) 10) (concat (substring s 0 10)  "...") s)) (org-roam-node-olp node)))
           (level (org-roam-node-level node))
           (filetitle (org-roam-get-keyword "TITLE" (org-roam-node-file node)))
           (filetitle-or-name (if filetitle filetitle (file-name-nondirectory (org-roam-node-file node))))
           (shortentitle (if (> (length filetitle-or-name) 20) (concat (substring filetitle-or-name 0 20)  "...") filetitle-or-name))
           (separator (concat " " (all-the-icons-material "chevron_right") " ")))
      (cond
       ((= level 1) (concat (propertize (format "=level:%d=" level) 'display (all-the-icons-faicon "file" :face 'all-the-icons-dyellow :v-adjust 0.04 "  "))
                            (propertize shortentitle 'face 'org-roam-olp) separator title))
       ((= level 2) (concat (propertize (format "=level:%d=" level) 'display (all-the-icons-faicon "file" :face 'all-the-icons-dsilver :v-adjust 0.04 "  "))
                            (propertize (concat shortentitle separator (string-join olp separator)) 'face 'org-roam-olp) separator title))
       ((> level 2) (concat (propertize (format "=level:%d=" level) 'display (all-the-icons-faicon "file" :face 'org-roam-olp :v-adjust 0.04 "  "))
                            (propertize (concat shortentitle separator (string-join olp separator)) 'face 'org-roam-olp) separator title))
       (t (concat (propertize (format "=level:%d=" level) 'display (all-the-icons-faicon "file" :face 'all-the-icons-yellow :v-adjust 0.04 "  "))
                  (if filetitle title (propertize filetitle-or-name 'face 'all-the-icons-dyellow)))))))

  (cl-defmethod org-roam-node-functiontag ((node org-roam-node))
    ;;    "Return the FUNCTION TAG for each node. These tags are intended to be unique to each file, and represent the note's function.
    ;;        journal data literature"
    (let* ((tags (seq-filter (lambda (tag) (not (string= tag "ATTACH"))) (org-roam-node-tags node))))
      (concat
       (cond
        ((member "emacs" tags)
         (propertize "=f:emacs=" 'display (all-the-icons-alltheicon "terminal" :face 'all-the-icons-silver :v-adjust 0.04)))
        (t (propertize "=f:empty=" 'display (all-the-icons-alltheicon "terminal" :face 'org-hide :v-adjust 0.04))))
       (cond
        ((member "people" tags)
         (propertize "=f:people=" 'display (all-the-icons-material "people" :face 'all-the-icons-dblue)))
        (t (propertize "=f:nothing=" 'display (all-the-icons-material "people" :face 'org-hide))))
       ;; literature
       (cond
        ((member "content" tags)
         (propertize "=f:content=" 'display (all-the-icons-material "book" :face 'all-the-icons-dcyan)))
        (t (propertize "=f:nothing=" 'display (all-the-icons-material "book" :face 'org-hide))))
       ;; journal
       )))

  (cl-defmethod org-roam-node-othertags ((node org-roam-node))
    "Return the OTHER TAGS of each notes."
    (let* ((tags (seq-filter (lambda (tag) (not (string= tag "ATTACH"))) (org-roam-node-tags node)))
           (specialtags hp/org-roam-function-tags)
           (othertags (seq-difference tags specialtags 'string=)))
      (concat
       (if othertags
           (propertize "=has:tags=" 'display (all-the-icons-faicon "tags" :face 'all-the-icons-dgreen :v-adjust 0.02))) " "
       (propertize (string-join othertags ", ") 'face 'all-the-icons-dgreen))))
  (cl-defmethod org-roam-node-backlinkscount ((node org-roam-node))
    (let* ((count (caar (org-roam-db-query
                         [:select (funcall count source)
                          :from links
                          :where (= dest $s1)
                          :and (= type "id")]
                         (org-roam-node-id node))))
           )
      (if (> count 0)
          (concat (propertize "=has:backlinks=" 'display (all-the-icons-material "link" :face 'all-the-icons-dblue :height 0.9)) (format "%d" count))
        (concat (propertize "=not-backlinks=" 'display (all-the-icons-material "link" :face 'org-roam-dim :height 0.9))  " ")
        )
      ))

  (after! org
    (font-lock-add-keywords 'org-mode
                            `(("^\\(#\\+title:\\)" 1 (prog1 nil (compose-region (match-beginning 1) (match-end 1) ,(all-the-icons-faicon "pencil-square"))))
                              ("^\\(:PROPERTIES:\\)" 1 (prog1 nil (compose-region (match-beginning 1) (match-end 1) ,(all-the-icons-faicon "paperclip"))))
                              ("^\\(:END:\\)" 1 (prog1 nil (compose-region (match-beginning 1) (match-end 1) ,(all-the-icons-faicon "ellipsis-h")))))))




  (cl-defmethod org-roam-node-directories ((node org-roam-node))
    (if-let ((dirs (file-name-directory (file-relative-name (org-roam-node-file node) org-roam-directory))))
        (concat
         (if (string= "journal/" dirs)
             (all-the-icons-faicon "calendar" :face 'all-the-icons-dsilver)
           (if (string= "research/" dirs)
               (all-the-icons-faicon "book" :face 'all-the-icons-dsilver :v-adjust 0.02)
             (if (string= "climbing/" dirs)
                 (all-the-icons-material "landscape" :face 'all-the-icons-dsilver )
               (if (string= "productivity/" dirs)
                   (all-the-icons-material "build" :face 'all-the-icons-dsilver )
                 (all-the-icons-material "folder" :face 'all-the-icons-dsilver))
               )))
         (propertize (string-join (f-split dirs) "/") 'face 'all-the-icons-dsilver) " ")
      ""))

  (setq org-roam-node-display-template
        (concat  "${backlinkscount:16} ${functiontag} ${directories}${hierarchy} ${othertags}"))
  )


(use-package! org-roam-ui
  :after org-roam ;; or :after org
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t))
;; display the time in the modeline
;;
(setq display-time-default-load-average nil)
(display-time-mode 1)

(unless (string-match-p "^Power N/A" (battery)) ; On laptops...
  (display-battery-mode 1)) ; it's nice to know how much power
                                        ; → you have

;; turn of global higlighting mode
(global-hl-line-mode -1)
(setq make-pointer-invisible t)
(setq  auto-save-default t)

;; Start Doom fullscreen
(add-to-list 'default-frame-alist '(width . 92))
(add-to-list 'default-frame-alist '(height . 35))
(add-to-list 'default-frame-alist '(alpha 97 100))

(setq +zen-text-scale 1)

;; make the pop up faster
(setq which-key-idle-delay 0.5) ;; I need the help, I really do

(after! evil
  (setq evil-ex-substitute-global t ; I like my s/../.. to by global by default
        )) ; Don't put overwritten text in the kill ring

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'visual)
(setq cursor-type nil)

(custom-set-faces
 '(org-level-1 ((t (:inherit outline-1 :height 1.2))))
 '(org-level-2 ((t (:inherit outline-2 :height 1.1))))
 )



(use-package! org-fragtog
  :hook
  (org-mode . org-fragtog-mode))

;; able to drag images into org mode files
(use-package! org-download
  :config
  (add-hook 'dired-mode-hook 'org-download-enable))

(use-package! org-superstar
  :after org
  :hook (org-mode . org-superstar-mode)
  :config
  (setq org-superstar-headline-bullets-list '("◉" "○" "✸" "◉" "○" "✸")))

(use-package! evil-vimish-fold
  :config
  (global-evil-vimish-fold-mode))

;; better highlighting of of vim commands
(use-package! evil-goggles
  :init
  (setq evil-goggles-enable-change t
        evil-goggles-enable-delete t
        evil-goggles-pulse         t
        evil-goggles-duration      0.15)
  :config
  (custom-set-faces!
    `((evil-goggles-yank-face evil-goggles-surround-face)
      :background ,(doom-blend (doom-color 'blue) (doom-color 'bg-alt) 0.5)
      :extend t)
    `(evil-goggles-paste-face
      :background ,(doom-blend (doom-color 'green) (doom-color 'bg-alt) 0.5)
      :extend t)
    `(evil-goggles-delete-face
      :background ,(doom-blend (doom-color 'red) (doom-color 'bg-alt) 0.5)
      :extend t)
    `(evil-goggles-change-face
      :background ,(doom-blend (doom-color 'orange) (doom-color 'bg-alt) 0.5)
      :extend t)
    `(evil-goggles-commentary-face
      :background ,(doom-blend (doom-color 'grey) (doom-color 'bg-alt) 0.5)
      :extend t)
    `((evil-goggles-indent-face evil-goggles-join-face evil-goggles-shift-face)
      :background ,(doom-blend (doom-color 'yellow) (doom-color 'bg-alt) 0.25)
      :extend t)
    ))
(use-package evil-surround
  :ensure t
  :config
  (global-evil-surround-mode 1))
;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
